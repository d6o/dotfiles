-- ~/.config/sketchybar/items/widgets/music.lua
local colors = require("colors")
local icons = require("icons")
local settings = require("settings")

-- --- tuning ---------------------------------------------------------------
local COVER_SIZE = 26
local COVER_SCALE = 0.04
local COVER_RADIUS = 5
local SHOW_ON_RIGHT = true
local POLL_SECONDS = 2.0
local STARTUP_DELAY = 0.5 -- avoid login race when launched by brew services

local function side()
	return SHOW_ON_RIGHT and "right" or "left"
end

-- temp artwork file (writable even when started by launchd)
local ART_PATH = "/tmp/sketchybar_music_art.jpg"

-- --- items ---------------------------------------------------------------
-- Cover first so text aligns right after it
local cover = sbar.add("item", "widgets.music.cover", {
	position = side(),
	background = {
		image = { string = ART_PATH, scale = COVER_SCALE, corner_radius = COVER_RADIUS },
		color = colors.transparent,
		height = COVER_SIZE,
	},
	icon = { drawing = false },
	label = { drawing = false },
	padding_left = 0,
	padding_right = 6,
	updates = true,
})

-- Two-line stack (artist top, title bottom)
local MAX_CHARS = 26

local artist = sbar.add("item", "widgets.music.artist", {
	position = side(),
	width = 0, -- overlay
	padding_left = 4,
	padding_right = 4,
	y_offset = -6, -- top line
	icon = { drawing = false },
	label = {
		max_chars = MAX_CHARS,
		align = "left",
		font = { style = settings.font.style_map["Semibold"], size = 10 },
		color = colors.grey,
	},
})

local title = sbar.add("item", "widgets.music.title", {
	position = side(),
	padding_left = 4,
	padding_right = 8,
	y_offset = 6, -- bottom line
	icon = { drawing = false },
	label = {
		max_chars = MAX_CHARS,
		align = "left",
		font = { style = settings.font.style_map["Bold"], size = 12 },
		color = colors.white,
	},
})

-- Controls removed - no longer needed

-- Chip bracket around (cover + texts)
sbar.add(
	"bracket",
	"widgets.music.bracket",
	{ artist.name, title.name, cover.name },
	{ background = { color = colors.bg1, border_color = colors.black, border_width = 1, height = 26 } }
)

sbar.add("item", "widgets.music.padding", {
	position = SHOW_ON_RIGHT and "right" or "left",
	width = settings.group_paddings,
})

-- --- actions --------------------------------------------------------------

for _, it in ipairs({ cover, title, artist }) do
	it:subscribe("mouse.clicked", function()
		sbar.exec([[open -a "Music"]])
	end)
end

-- --- AppleScript helpers (resilient) -------------------------------------
-- Return title, artist, player_state even if stopped/not running.
local APPLESCRIPT_INFO = [[
if application "Music" is running then
  tell application "Music"
    set ps to (player state as string)
    if ps is "stopped" then
      return "" & linefeed & "" & linefeed & ps
    end if
    try
      set t to name of current track
      set ar to artist of current track
      return t & linefeed & ar & linefeed & ps
    on error
      return "" & linefeed & "" & linefeed & ps
    end try
  end tell
end if
return "" & linefeed & "" & linefeed & "not_running"
]]

-- Writes current artwork to ART_PATH (returns "ok"/"")
local APPLESCRIPT_ART = ([[
if application "Music" is running then
  tell application "Music"
    try
      if (player state as string) is "stopped" then return ""
      if (count of artworks of current track) is 0 then return ""
      set outFile to POSIX file "%s"
      set d to data of artwork 1 of current track
      try
        set fh to open for access outFile with write permission
        set eof of fh to 0
        write d to fh
        close access fh
      on error
        try
          close access outFile
        end try
        return ""
      end try
      return "ok"
    on error
      return ""
    end try
  end tell
end if
return ""
]]):format(ART_PATH)

-- --- rendering ------------------------------------------------------------
local function ensure_visible()
	-- only turn items on; do NOT touch labels
	cover:set({ drawing = "on" })
	title:set({ drawing = "on" })
	artist:set({ drawing = "on" })
end

local function show_placeholder()
	ensure_visible()
	-- only use placeholders when we truly have no metadata
	title:set({ label = { string = "—" } })
	artist:set({ label = { string = "" } })
end

local function refresh_once()
	sbar.exec("/usr/bin/osascript -e '" .. APPLESCRIPT_INFO:gsub("'", [["]]) .. "'", function(meta)
		if not meta then
			show_placeholder()
			return
		end

		local lines, i = {}, 0
		for line in string.gmatch(meta, "[^\r\n]+") do
			lines[#lines + 1] = line
		end
		local t = lines[1] or ""
		local ar = lines[2] or ""
		local st = lines[3] or "not_running"

		-- Update texts (keep widget visible regardless of state)
		title:set({ label = { string = (t ~= "" and t or "—") } })
		artist:set({ label = { string = (ar ~= "" and ar or "") } })

		-- Try to fetch art; keep previous art on failure
		sbar.exec("/usr/bin/osascript -e '" .. APPLESCRIPT_ART:gsub("'", [["]]) .. "'", function(ok)
			if ok and ok:match("ok") then
				cover:set({
					background = {
						height = COVER_SIZE,
						image = { string = ART_PATH, scale = COVER_SCALE, corner_radius = COVER_RADIUS },
					},
				})
			end
			ensure_visible()
		end)
	end)
end

local function loop()
	refresh_once()
	sbar.delay(POLL_SECONDS, loop)
end

-- small delay at login helps when started by brew services
sbar.delay(STARTUP_DELAY, loop)

-- also refresh on wake
cover:subscribe("system_woke", refresh_once)
