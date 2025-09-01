vim.opt.guicursor = ""
vim.g.mapleader = " "

vim.opt.cmdheight = 1  -- Only use 1 line for command line
vim.opt.showmode = false  -- Turn OFF mode display (lualine shows it)
vim.opt.showcmd = false   -- Turn OFF command display
vim.opt.ruler = false     -- Turn OFF ruler (lualine shows position)

vim.opt.nu = true
vim.opt.relativenumber = true

vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

vim.opt.smartindent = true

vim.opt.wrap = false

vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.opt.undofile = true

vim.opt.hlsearch = false
vim.opt.incsearch = true

vim.opt.termguicolors = true

vim.opt.scrolloff = 8 
vim.opt.signcolumn = "yes"
vim.opt.isfname:append("@-@")

vim.opt.updatetime = 50

vim.opt.colorcolumn = "80"

vim.opt.confirm = true2
