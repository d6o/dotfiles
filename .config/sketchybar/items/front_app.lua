local colors = require("colors")
local settings = require("settings")

-- Add a small padding item to push front_app after workspaces
sbar.add("item", "front_app.padding", {
  position = "left",
  width = 10,
})

local front_app = sbar.add("item", "front_app", {
  display = "active",
  position = "left",
  icon = { drawing = false },
  label = {
    font = {
      style = settings.font.style_map["Black"],
      size = 12.0,
    },
  },
  updates = true,
})

front_app:subscribe("front_app_switched", function(env)
  front_app:set({ label = { string = env.INFO } })
end)

front_app:subscribe("mouse.clicked", function(env)
  sbar.trigger("swap_menus_and_spaces")
end)
