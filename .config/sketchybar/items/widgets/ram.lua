local icons = require("icons")
local colors = require("colors")
local settings = require("settings")

-- Execute the event provider binary which provides the event "ram_update" for
-- the ram usage data, which is fired every 2.0 seconds.
sbar.exec("killall ram_load >/dev/null; $CONFIG_DIR/helpers/event_providers/ram_load/ram_load ram_update 2.0")

local ram = sbar.add("graph", "widgets.ram", 42, {
  position = "right",
  graph = { color = colors.green },
  background = {
    height = 22,
    color = { alpha = 0 },
    border_color = { alpha = 0 },
    drawing = true,
  },
  icon = { string = icons.ram or "􀫦" }, -- memory chip icon
  label = {
    string = "ram ??%",
    font = {
      family = settings.font.numbers,
      style = settings.font.style_map["Bold"],
      size = 9.0,
    },
    align = "right",
    padding_right = 0,
    width = 0,
    y_offset = 4
  },
  padding_right = settings.paddings + 6
})

ram:subscribe("ram_update", function(env)
  -- Available: env.total_memory, env.used_memory, env.free_memory, env.usage_percent
  local usage_percent = tonumber(env.usage_percent)
  ram:push({ usage_percent / 100.0 })

  -- Color based on usage
  local color = colors.green
  if usage_percent > 50 then
    if usage_percent < 70 then
      color = colors.yellow
    elseif usage_percent < 85 then
      color = colors.orange
    else
      color = colors.red
    end
  end

  ram:set({
    graph = { color = color },
    label = "ram " .. env.usage_percent .. "%",
  })
end)

-- Click to open Activity Monitor
ram:subscribe("mouse.clicked", function(env)
  sbar.exec("open -a 'Activity Monitor'")
end)

-- Background around the ram item
sbar.add("bracket", "widgets.ram.bracket", { ram.name }, {
  background = { color = colors.bg1 }
})

-- Padding after the ram item
sbar.add("item", "widgets.ram.padding", {
  position = "right",
  width = settings.group_paddings
})

