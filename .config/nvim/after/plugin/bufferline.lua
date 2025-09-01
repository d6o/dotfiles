local status_ok, bufferline = pcall(require, "bufferline")
if not status_ok then
  vim.notify("bufferline not found!")
  return
end

bufferline.setup({
  options = {
    mode = "buffers", -- set to "tabs" to only show tabpages instead
    numbers = "none", -- | "ordinal" | "buffer_id" | "both" | function({ ordinal, id, lower, raise }): string,
    close_command = "bdelete! %d", -- can be a string | function, see "Mouse actions"
    right_mouse_command = "bdelete! %d", -- can be a string | function, see "Mouse actions"
    left_mouse_command = "buffer %d", -- can be a string | function, see "Mouse actions"
    middle_mouse_command = nil, -- can be a string | function, see "Mouse actions"
    
    indicator = {
      icon = '▎', -- this should be omitted if indicator style is not 'icon'
      style = 'icon', -- | 'underline' | 'none',
    },
    
    buffer_close_icon = '󰅖',
    modified_icon = '●',
    close_icon = '',
    left_trunc_marker = '',
    right_trunc_marker = '',
    
    --- name_formatter can be used to change the buffer's label in the bufferline.
    name_formatter = function(buf)  -- buf contains:
      -- name                | str        | the basename of the active file
      -- path                | str        | the full path of the active file
      -- bufnr (buffer only) | int        | the number of the active buffer
      -- buffers (tabs only) | table(int) | the numbers of the buffers in the tab
      -- tabnr (tabs only)   | int        | the "handle" of the tab, can be converted to its ordinal number using: `vim.api.nvim_tabpage_get_number(buf.tabnr)`
      return buf.name
    end,
    
    max_name_length = 18,
    max_prefix_length = 15, -- prefix used when a buffer is de-duplicated
    truncate_names = true, -- whether or not tab names should be truncated
    tab_size = 18,
    
    diagnostics = "nvim_lsp", -- | "coc" | false,
    diagnostics_update_in_insert = false,
    
    -- The diagnostics indicator can be set to nil to keep the buffer name highlight but delete the highlighting
    diagnostics_indicator = function(count, level, diagnostics_dict, context)
      local s = " "
      for e, n in pairs(diagnostics_dict) do
        local sym = e == "error" and " "
          or (e == "warning" and " " or "")
        s = s .. n .. sym
      end
      return s
    end,
    
    offsets = {
      {
        filetype = "NvimTree",
        text = "File Explorer",
        text_align = "center",
        separator = true
      }
    },
    
    color_icons = true, -- whether or not to add the filetype icon highlights
    
    show_buffer_icons = true, -- disable filetype icons for buffers
    show_buffer_close_icons = true,
    show_close_icon = true,
    show_tab_indicators = true,
    show_duplicate_prefix = true, -- whether to show duplicate buffer prefix
    
    persist_buffer_sort = true, -- whether or not custom sorted buffers should persist
    
    -- can also be a table containing 2 custom separators
    -- [focused and unfocused]. eg: { '|', '|' }
    separator_style = "thin", -- | "thick" | "thin" | { 'any', 'any' },
    
    enforce_regular_tabs = false,
    always_show_bufferline = true,
    
    hover = {
      enabled = true,
      delay = 200,
      reveal = {'close'}
    },
    
    sort_by = 'insert_after_current',
  }
})

-- Keymaps for buffer navigation
local keymap = vim.keymap.set
local opts = { noremap = true, silent = true }

-- Navigate buffers
keymap("n", "<S-l>", ":BufferLineCycleNext<CR>", opts)  -- Shift + l to go to next buffer
keymap("n", "<S-h>", ":BufferLineCyclePrev<CR>", opts)  -- Shift + h to go to previous buffer

-- Move buffers
keymap("n", "<leader>bn", ":BufferLineMoveNext<CR>", opts)  -- Move buffer to the right
keymap("n", "<leader>bp", ":BufferLineMovePrev<CR>", opts)  -- Move buffer to the left

-- Pin/unpin buffer
keymap("n", "<leader>bP", ":BufferLineTogglePin<CR>", opts)

-- Close buffers
keymap("n", "<leader>bx", ":Bdelete<CR>", opts)   -- Close current buffer (smart)
keymap("n", "<leader>bD", ":Bdelete!<CR>", opts)  -- Force close current buffer (smart)

keymap("n", "<leader>br", ":BufferLineCloseRight<CR>", opts)  -- Close all buffers to the right
keymap("n", "<leader>bl", ":BufferLineCloseLeft<CR>", opts)   -- Close all buffers to the left
keymap("n", "<leader>bo", ":BufferLineCloseOthers<CR>", opts) -- Close all other buffers

-- Pick buffer
keymap("n", "<leader>bj", ":BufferLinePick<CR>", opts)  -- Jump to buffer by letter
keymap("n", "<leader>bc", ":BufferLinePickClose<CR>", opts)  -- Close buffer by letter

-- Sort buffers
keymap("n", "<leader>bse", ":BufferLineSortByExtension<CR>", opts)
keymap("n", "<leader>bsd", ":BufferLineSortByDirectory<CR>", opts)

-- Quick navigation to specific buffers (1-9)
for i = 1, 9 do
  keymap("n", "<leader>" .. i, ":BufferLineGoToBuffer " .. i .. "<CR>", opts)
end

