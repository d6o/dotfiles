-- ~/.config/sketchybar/items/aerospace_workspaces.lua
--
-- AeroSpace Workspace Integration for SketchyBar
-- Creates workspace indicators that show on their respective monitors,
-- display app icons for windows in each workspace, and handle click interactions

local colors = require("colors")
local settings = require("settings")
local app_icons = require("helpers.app_icons")

-- Register the custom event that AeroSpace will emit
sbar.add("event", "aerospace_workspace_change")

-- ============================================================================
-- CONFIGURATION
-- ============================================================================

-- Workspace layout configuration
-- Display mapping: 3 = left monitor, 1 = middle monitor, 2 = right monitor
-- Each workspace will only appear on its designated monitor's bar
local WORKSPACE_LAYOUT = {
	{ display = 1, workspaces = { "1", "2", "3", "4", "5", "6", "7", "8", "9" } }, -- left monitor
	{ display = 1, workspaces = { "Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P" } }, -- middle monitor
	{ display = 1, workspaces = { "A", "S", "D", "F", "G", "M", "N", "Z", "X", "C", "V", "B" } }, -- right monitor
}

-- Visual styling constants
local STYLE = {
	chip_bg = colors.bg1, -- Background color for workspace chips
	chip_border = colors.black, -- Border color for workspace chips
	chip_height = 26, -- Height of workspace chips
	bracket_border = colors.bg2, -- Border color for workspace brackets
	active_icon_highlight = colors.red, -- Highlight color for active workspace icon
	active_label_highlight = colors.white, -- Highlight color for active workspace label
	inactive_icon_color = colors.white, -- Color for inactive workspace icons
	inactive_label_color = colors.grey, -- Color for inactive workspace labels
}

-- ============================================================================
-- STATE MANAGEMENT
-- ============================================================================

-- Storage for workspace items and their associated elements
local workspace_items = {} -- workspace -> { item, bracket, display }
local padding_items = {} -- workspace -> padding item name
local separator_items = {} -- display -> separator item name
local workspace_groups = {} -- app_set_hash -> { workspaces = {}, item, bracket, display, app_icons, last_access = timestamp }
local workspace_to_group = {} -- workspace -> app_set_hash
local previous_workspace_state = {} -- workspace -> app_list (for change detection)
local workspace_access_times = {} -- workspace -> timestamp (for MRU ordering)
local previous_focused_workspace = nil -- track focus changes

-- Build workspace -> display mapping for fast lookups
-- This allows us to quickly determine which monitor a workspace belongs to
local workspace_to_display = {}
for _, group in ipairs(WORKSPACE_LAYOUT) do
	for _, ws in ipairs(group.workspaces) do
		workspace_to_display[ws] = group.display
	end
end

-- ============================================================================
-- WORKSPACE ACCESS TRACKING (for MRU ordering)
-- ============================================================================

-- Updates the access time for a workspace
local function update_workspace_access_time(workspace)
	workspace_access_times[workspace] = os.time()
end

-- Gets the most recent access time for any workspace in a group
local function get_group_last_access_time(group_data)
	local most_recent = 0
	for _, ws in ipairs(group_data.workspaces) do
		local access_time = workspace_access_times[ws] or 0
		if access_time > most_recent then
			most_recent = access_time
		end
	end
	return most_recent
end

-- ============================================================================
-- WORKSPACE GROUPING FUNCTIONS
-- ============================================================================

-- Creates a hash from a sorted list of apps for grouping workspaces
local function create_app_set_hash(app_list)
	table.sort(app_list)
	return table.concat(app_list, "|")
end

-- Gets the list of apps in a workspace
local function get_workspace_apps(ws, callback)
	sbar.exec(string.format('aerospace list-windows --workspace %s --format "%%{app-name}"', ws), function(output)
		local apps = {}
		for app_name in string.gmatch(output or "", "[^\r\n]+") do
			app_name = app_name:gsub("^%s+", ""):gsub("%s+$", "") -- Trim whitespace
			if app_name ~= "" then
				table.insert(apps, app_name)
			end
		end
		callback(apps)
	end)
end

-- Helper function to sort workspaces in a logical order (numbers first, then letters)
local function sort_workspaces(workspaces)
	local numbers = {}
	local letters = {}
	
	for _, ws in ipairs(workspaces) do
		if tonumber(ws) then
			table.insert(numbers, ws)
		else
			table.insert(letters, ws)
		end
	end
	
	-- Sort numbers numerically and letters alphabetically
	table.sort(numbers, function(a, b) return tonumber(a) < tonumber(b) end)
	table.sort(letters)
	
	-- Combine: numbers first, then letters
	local sorted = {}
	for _, num in ipairs(numbers) do table.insert(sorted, num) end
	for _, letter in ipairs(letters) do table.insert(sorted, letter) end
	
	return sorted
end

-- Creates a grouped workspace item for workspaces with identical app sets
local function create_grouped_workspace_item(app_set_hash, workspaces, display, app_icons_string)
	-- Sort workspaces in logical order
	local sorted_workspaces = sort_workspaces(workspaces)
	local workspace_label = table.concat(sorted_workspaces, ",")
	
	local item = sbar.add("item", "aws.group." .. app_set_hash, {
		position = "left",
		display = display,
		icon = {
			font = { family = settings.font.numbers },
			string = workspace_label,
			padding_left = 8,
			padding_right = 4,
			color = STYLE.inactive_icon_color,
			highlight_color = STYLE.active_icon_highlight,
		},
		label = {
			padding_right = 8,
			color = STYLE.inactive_label_color,
			highlight_color = STYLE.active_label_highlight,
			font = "sketchybar-app-font:Regular:16.0",
			y_offset = -1,
			string = app_icons_string,
		},
		padding_right = 1,
		padding_left = 1,
		background = {
			color = STYLE.chip_bg,
			border_width = 1,
			height = STYLE.chip_height,
			border_color = STYLE.chip_border,
		},
		drawing = "off",
	})

	local bracket = sbar.add("bracket", { item.name }, {
		display = display,
		background = {
			color = colors.transparent,
			border_color = STYLE.bracket_border,
			height = STYLE.chip_height + 2,
			border_width = 2,
		},
		drawing = "off",
	})

	return item, bracket
end

-- ============================================================================
-- ITEM CREATION FUNCTIONS
-- ============================================================================

-- Creates a workspace item (the clickable chip that shows the workspace)
local function create_workspace_item(ws)
	local display = workspace_to_display[ws] or "active"

	local item = sbar.add("item", "aws." .. ws, {
		position = "left",
		display = display, -- Pin this chip to its designated monitor
		icon = {
			font = { family = settings.font.numbers },
			string = ws, -- Display the workspace name/letter
			padding_left = 8,
			padding_right = 4,
			color = STYLE.inactive_icon_color,
			highlight_color = STYLE.active_icon_highlight,
		},
		label = {
			padding_right = 8,
			color = STYLE.inactive_label_color,
			highlight_color = STYLE.active_label_highlight,
			font = "sketchybar-app-font:Regular:16.0", -- Use app font for icons
			y_offset = -1,
		},
		padding_right = 1,
		padding_left = 1,
		background = {
			color = STYLE.chip_bg,
			border_width = 1,
			height = STYLE.chip_height,
			border_color = STYLE.chip_border,
		},
		click_script = "aerospace workspace " .. ws, -- Left click switches to workspace
		drawing = "off", -- Initially hidden
	})

	-- Create a bracket around the workspace item for visual grouping
	local bracket = sbar.add("bracket", { item.name }, {
		display = display, -- Bracket appears on same monitor as the item
		background = {
			color = colors.transparent,
			border_color = STYLE.bracket_border,
			height = STYLE.chip_height + 2,
			border_width = 2,
		},
		drawing = "off", -- Initially hidden
	})

	-- Handle right-click to move focused window to this workspace
	item:subscribe("mouse.clicked", function(env)
		if env.BUTTON == "right" then
			sbar.exec("aerospace move-node-to-workspace " .. ws)
		end
	end)

	return item, bracket
end

-- Creates a padding item for spacing between workspace groups
local function create_padding_item(ws, display)
	return sbar.add("item", "aws.pad." .. ws, {
		position = "left",
		display = display,
		width = settings.group_paddings,
		drawing = "off", -- Initially hidden
	})
end

-- Ensures a workspace item exists, creating it if necessary
local function ensure_workspace_exists(ws)
	if workspace_items[ws] then
		return workspace_items[ws]
	end

	local display = workspace_to_display[ws] or "active"
	local item, bracket = create_workspace_item(ws)
	local pad = create_padding_item(ws, display)

	-- Store references to all created items
	workspace_items[ws] = { item = item, bracket = bracket, display = display }
	padding_items[ws] = pad.name

	return workspace_items[ws]
end

-- Creates separator items between monitor groups
local function create_separators()
	for _, group in ipairs(WORKSPACE_LAYOUT) do
		local display = group.display
		if not separator_items[display] then
			local sep = sbar.add("item", string.format("aws.sep.%d", display), {
				position = "left",
				display = display,
				width = settings.group_paddings, -- Reduced width for tighter spacing
				drawing = "off", -- Initially hidden
			})
			separator_items[display] = sep.name
		end
	end
end

-- ============================================================================
-- VISIBILITY AND STYLING FUNCTIONS
-- ============================================================================

-- Shows or hides a workspace and its associated elements
local function set_workspace_visibility(ws, visible)
	local workspace = ensure_workspace_exists(ws)
	local drawing_state = visible and "on" or "off"

	-- Show/hide the main workspace item, bracket, and padding
	workspace.item:set({ drawing = drawing_state })
	workspace.bracket:set({ drawing = drawing_state })
	sbar.set(padding_items[ws], { drawing = drawing_state })
end

-- Updates the visual appearance of a workspace based on its state and contents
local function update_workspace_appearance(ws, focused_workspace)
	local workspace = workspace_items[ws]
	if not workspace then
		return
	end

	local is_focused = (ws == focused_workspace)

	-- Get list of applications running in this workspace
	sbar.exec(string.format('aerospace list-windows --workspace %s --format "%%{app-name}"', ws), function(output)
		local seen_apps = {}
		local app_icons_string = ""

		-- Parse application names and build icon string
		for app_name in string.gmatch(output or "", "[^\r\n]+") do
			app_name = app_name:gsub("^%s+", ""):gsub("%s+$", "") -- Trim whitespace

			-- Only add unique apps to avoid duplicate icons
			if app_name ~= "" and not seen_apps[app_name] then
				seen_apps[app_name] = true
				local icon = app_icons[app_name] or app_icons["Default"] or "·"
				app_icons_string = app_icons_string .. icon
			end
		end

		-- Show placeholder when workspace is empty
		if app_icons_string == "" then
			app_icons_string = " —"
		end

		-- Update workspace visual state with proper highlighting
		workspace.item:set({
			icon = { highlight = is_focused },
			label = { string = app_icons_string, highlight = is_focused },
			background = {
				border_color = is_focused and STYLE.chip_border or STYLE.bracket_border,
			},
		})

		-- Update bracket styling with focus indication
		workspace.bracket:set({
			background = {
				border_color = is_focused and colors.grey or STYLE.bracket_border,
			},
		})
	end)
end

-- ============================================================================
-- SEPARATOR MANAGEMENT
-- ============================================================================

-- Updates visibility of separators between workspace groups
local function update_separators()
	-- Check each display for visible grouped items
	local display_has_visible = {}
	for _, group_data in pairs(workspace_groups) do
		if group_data.item and group_data.item:query().geometry.drawing == "on" then
			display_has_visible[group_data.display] = true
		end
	end

	-- Show/hide separators based on adjacent displays having visible items
	for i = 1, (#WORKSPACE_LAYOUT - 1) do
		local left_display = WORKSPACE_LAYOUT[i].display
		local right_display = WORKSPACE_LAYOUT[i + 1].display

		local sep_name = separator_items[left_display]
		if sep_name then
			sbar.set(sep_name, {
				drawing = (display_has_visible[left_display] and display_has_visible[right_display]) and "on" or "off",
			})
		end
	end
end

-- ============================================================================
-- MAIN UPDATE LOGIC
-- ============================================================================

-- Helper function to check if two app lists are identical
local function apps_equal(apps1, apps2)
	if #apps1 ~= #apps2 then return false end
	local sorted1, sorted2 = {}, {}
	for i, app in ipairs(apps1) do sorted1[i] = app end
	for i, app in ipairs(apps2) do sorted2[i] = app end
	table.sort(sorted1)
	table.sort(sorted2)
	for i = 1, #sorted1 do
		if sorted1[i] ~= sorted2[i] then return false end
	end
	return true
end

-- Main function that updates all workspace visibility and styling with grouping
local function update_all_workspaces()
	-- Get the currently focused workspace from AeroSpace
	sbar.exec("aerospace list-workspaces --focused", function(focused_output)
		local focused_workspace = (focused_output or ""):gsub("%s+", "")
		
		-- Update access time for the currently focused workspace
		if focused_workspace and focused_workspace ~= "" then
			update_workspace_access_time(focused_workspace)
		end

		-- Collect current workspace states
		local current_workspace_state = {}
		local visible_workspaces = {}
		local pending_workspaces = 0
		local processed_workspaces = 0

		-- Count total workspaces to process
		for _, group in ipairs(WORKSPACE_LAYOUT) do
			for _, ws in ipairs(group.workspaces) do
				pending_workspaces = pending_workspaces + 1
			end
		end

		-- Process each workspace to get its current apps
		for _, group in ipairs(WORKSPACE_LAYOUT) do
			for _, ws in ipairs(group.workspaces) do
				get_workspace_apps(ws, function(apps)
					local has_windows = #apps > 0
					local should_show = (ws == focused_workspace) or has_windows

					current_workspace_state[ws] = apps
					if should_show then
						visible_workspaces[ws] = apps
					end

					processed_workspaces = processed_workspaces + 1
					if processed_workspaces == pending_workspaces then
						-- Check if we need to update groups
						local needs_update = false
						
						-- Check if focus changed (to trigger MRU reordering)
						if focused_workspace and focused_workspace ~= previous_focused_workspace then
							needs_update = true
							previous_focused_workspace = focused_workspace
						end
						
						-- Check for changes in workspace states
						for ws, apps in pairs(current_workspace_state) do
							if not previous_workspace_state[ws] or not apps_equal(previous_workspace_state[ws], apps) then
								needs_update = true
								break
							end
						end
						
						-- Check for removed workspaces
						for ws, _ in pairs(previous_workspace_state) do
							if not current_workspace_state[ws] then
								needs_update = true
								break
							end
						end

						-- Only force MRU reordering if content actually changed
						if needs_update then
							-- Delete all current groups to force recreation in MRU order
							for hash, group_data in pairs(workspace_groups) do
								if group_data.item then
									sbar.remove(group_data.item.name)
									sbar.remove(group_data.bracket.name)
								end
							end

							-- Reset groups
							workspace_groups = {}
							workspace_to_group = {}

							-- Rebuild groups
							for ws, apps in pairs(visible_workspaces) do
								local app_set_hash = create_app_set_hash(apps)
								local display = workspace_to_display[ws] or "active"

								if not workspace_groups[app_set_hash] then
									-- Create app icons string
									local seen_apps = {}
									local app_icons_string = ""
									for _, app_name in ipairs(apps) do
										if not seen_apps[app_name] then
											seen_apps[app_name] = true
											local icon = app_icons[app_name] or app_icons["Default"] or "·"
											app_icons_string = app_icons_string .. icon
										end
									end
									if app_icons_string == "" then
										app_icons_string = " —"
									end

									-- Create new group
									workspace_groups[app_set_hash] = {
										workspaces = { ws },
										display = display,
										app_icons = app_icons_string,
										apps = apps
									}
								else
									-- Add to existing group if same display
									if workspace_groups[app_set_hash].display == display then
										table.insert(workspace_groups[app_set_hash].workspaces, ws)
									else
										-- Different display, create separate group
										local new_hash = app_set_hash .. "_" .. display
										workspace_groups[new_hash] = {
											workspaces = { ws },
											display = display,
											app_icons = workspace_groups[app_set_hash].app_icons,
											apps = apps
										}
									end
								end
								workspace_to_group[ws] = app_set_hash
							end

							-- Create/update grouped items (sorted by most recently used)
							local sorted_groups = {}
							for hash, group_data in pairs(workspace_groups) do
								-- Always sort workspaces within each group for consistent display
								group_data.workspaces = sort_workspaces(group_data.workspaces)
								-- Add the group to our list for MRU sorting
								table.insert(sorted_groups, {hash = hash, data = group_data})
							end
							
							-- Sort groups by most recent access time (most recent first)
							table.sort(sorted_groups, function(a, b)
								local time_a = get_group_last_access_time(a.data)
								local time_b = get_group_last_access_time(b.data)
								return time_a > time_b
							end)
							
							-- Create groups in MRU order (they're always new since we deleted them)
							for _, group_info in ipairs(sorted_groups) do
								local hash = group_info.hash
								local group_data = group_info.data
								
								local item, bracket = create_grouped_workspace_item(hash, group_data.workspaces, group_data.display, group_data.app_icons)
								group_data.item = item
								group_data.bracket = bracket

								-- Set up click handlers for grouped workspaces
								item:subscribe("mouse.clicked", function(env)
									if env.BUTTON == "left" then
										-- Left click: switch to next workspace in group (using sorted order)
										local current_index = 1
										for i, ws in ipairs(group_data.workspaces) do
											if ws == focused_workspace then
												current_index = i
												break
											end
										end
										-- Cycle to next workspace or first if none are focused
										local next_index = (current_index % #group_data.workspaces) + 1
										sbar.exec("aerospace workspace " .. group_data.workspaces[next_index])
									elseif env.BUTTON == "right" then
										-- Right click: move focused window to first workspace in group
										sbar.exec("aerospace move-node-to-workspace " .. group_data.workspaces[1])
									end
								end)
							end

							-- Store current state for next comparison
							previous_workspace_state = current_workspace_state
						end

						-- Always update focus highlighting (this is lightweight)
						-- Create sorted list of groups for consistent ordering
						local focus_sorted_groups = {}
						for hash, group_data in pairs(workspace_groups) do
							table.insert(focus_sorted_groups, {hash = hash, data = group_data})
						end
						
						-- Sort groups by most recent access time (most recent first)
						table.sort(focus_sorted_groups, function(a, b)
							local time_a = get_group_last_access_time(a.data)
							local time_b = get_group_last_access_time(b.data)
							return time_a > time_b
						end)
						
						-- Update focus highlighting in MRU order
						for _, group_info in ipairs(focus_sorted_groups) do
							local group_data = group_info.data
							if group_data.item then
								-- Check if any workspace in group is focused
								local is_focused = false
								for _, ws in ipairs(group_data.workspaces) do
									if ws == focused_workspace then
										is_focused = true
										break
									end
								end

								-- Update appearance
								group_data.item:set({
									icon = { highlight = is_focused },
									label = { highlight = is_focused },
									background = {
										border_color = is_focused and STYLE.chip_border or STYLE.bracket_border,
									},
									drawing = "on"
								})

								group_data.bracket:set({
									background = {
										border_color = is_focused and colors.grey or STYLE.bracket_border,
									},
									drawing = "on"
								})
							end
						end

						update_separators()
					end
				end)
			end
		end
	end)
end

-- ============================================================================
-- INITIALIZATION
-- ============================================================================

-- Create all workspace items upfront
for _, group in ipairs(WORKSPACE_LAYOUT) do
	for _, ws in ipairs(group.workspaces) do
		ensure_workspace_exists(ws)
	end
end

-- Create separator items
create_separators()


-- Set up event observer for AeroSpace workspace changes
sbar.add("item", "aws.observer", { drawing = "off", updates = true })
	:subscribe("aerospace_workspace_change", function(_)
		-- Direct update - now that Aerospace events work properly
		update_all_workspaces()
	end)

-- Set up periodic refresh to catch window open/close events
-- that don't trigger workspace changes (much less frequent now)
local function periodic_refresh()
	update_all_workspaces()
	sbar.delay(30, periodic_refresh) -- Refresh every 30 seconds (events handle most updates)
end

-- Add a separator after workspaces to ensure front_app appears after
sbar.add("item", "workspaces.separator", {
	position = "left",
	width = 5,
	drawing = "on",
})

-- Perform initial update and start periodic refresh
update_all_workspaces()
periodic_refresh()
