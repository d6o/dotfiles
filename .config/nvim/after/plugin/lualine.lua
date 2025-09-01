local status_ok, lualine = pcall(require, "lualine")
if not status_ok then
  return
end

lualine.setup({
  options = {
    theme = 'tokyonight',  -- or 'gruvbox', 'tokyonight', etc.
    section_separators = { left = '', right = '' },
    component_separators = { left = '', right = '' },
    globalstatus = true,  -- Single statusline for all windows
  },
})

