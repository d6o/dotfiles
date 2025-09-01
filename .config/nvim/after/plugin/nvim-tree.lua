local status_ok, nvim_tree = pcall(require, "nvim-tree")
if not status_ok then
  return
end

-- Disable netrw
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Set termguicolors for better colors
vim.opt.termguicolors = true

-- Configure nvim-tree
nvim_tree.setup({
  sort_by = "case_sensitive",
  view = {
    width = 30,
    side = "left",
    preserve_window_proportions = true,
  },
  renderer = {
    group_empty = true,
    highlight_git = true,
    icons = {
      show = {
        git = true,
        folder = true,
        file = true,
        folder_arrow = true,
      },
      glyphs = {
        git = {
          unstaged = "✗",
          staged = "✓",
          unmerged = "",
          renamed = "➜",
          untracked = "★",
          deleted = "",
          ignored = "◌",
        },
      },
    },
  },
  filters = {
    dotfiles = false,  -- Show dotfiles
    custom = { "^.git$" }, -- Hide .git folder
  },
  git = {
    enable = true,
    ignore = false,
  },
  actions = {
    open_file = {
      quit_on_open = false,
      resize_window = true,
    },
  },
})

-- Keymaps
local keymap = vim.keymap.set
local opts = { noremap = true, silent = true }

keymap('n', '<leader>e', ':NvimTreeToggle<CR>', vim.tbl_extend('force', opts, { desc = 'Toggle file explorer' }))
keymap('n', '<leader>ef', ':NvimTreeFindFile<CR>', vim.tbl_extend('force', opts, { desc = 'Find current file in explorer' }))
keymap('n', '<leader>ec', ':NvimTreeCollapse<CR>', vim.tbl_extend('force', opts, { desc = 'Collapse file explorer' }))
keymap('n', '<leader>er', ':NvimTreeRefresh<CR>', vim.tbl_extend('force', opts, { desc = 'Refresh file explorer' }))

vim.keymap.set("n", "<leader>pv", function()
  local api = require("nvim-tree.api")
  if not api.tree.is_visible() then
    api.tree.find_file({ open = true, focus = true })
  else
    api.tree.close()
  end
end)

-- Optional: Auto-open nvim-tree when starting nvim with a directory
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function(data)
    -- buffer is a directory
    local directory = vim.fn.isdirectory(data.file) == 1
    if directory then
      -- change to the directory
      vim.cmd.cd(data.file)
      -- open the tree
      require("nvim-tree.api").tree.open()
    end
  end
})

