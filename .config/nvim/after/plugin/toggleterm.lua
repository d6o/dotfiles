-- Check if toggleterm is installed
local status_ok, toggleterm = pcall(require, "toggleterm")
if not status_ok then
    vim.notify("toggleterm not found!")
    return
end

toggleterm.setup({
    size = function(term)
        if term.direction == "horizontal" then
            return 15  -- Fixed 15 lines height
        elseif term.direction == "vertical" then
            return vim.o.columns * 0.4  -- 40% of screen width
        end
    end,
    open_mapping = [[<c-\>]],  -- Ctrl+\ to toggle terminal
    hide_numbers = true,
    shade_terminals = true,
    shading_factor = 2,
    start_in_insert = true,
    insert_mappings = true,
    terminal_mappings = true,
    persist_size = false,  -- Don't persist size changes
    persist_mode = true,
    direction = "horizontal",
    close_on_exit = true,
    shell = vim.o.shell,
    auto_scroll = true,
    -- This helps prevent the terminal from taking over
    on_create = function(t)
        vim.opt_local.foldcolumn = "0"
        vim.opt_local.signcolumn = "no"
    end,
    on_open = function(t)
        -- Ensure consistent size when opening
        if t.direction == "horizontal" then
            vim.cmd("resize 15")
        end
        -- Hide the statusline for this terminal window
        vim.opt_local.laststatus = 0
        vim.cmd("setlocal statusline=\\ ")  -- Set empty statusline
        vim.cmd("setlocal noshowmode")      -- Don't show mode in command line
        vim.cmd("setlocal noruler")         -- Don't show ruler
    end,
})

-- Terminal keymaps for navigation
function _G.set_terminal_keymaps()
    local opts = {buffer = 0}
    vim.keymap.set('t', '<esc>', [[<C-\><C-n>]], opts)  -- Escape to normal mode
    vim.keymap.set('t', 'jk', [[<C-\><C-n>]], opts)     -- jk to normal mode (alternative)
    vim.keymap.set('t', '<C-h>', [[<Cmd>wincmd h<CR>]], opts)  -- Navigate to left window
    vim.keymap.set('t', '<C-j>', [[<Cmd>wincmd j<CR>]], opts)  -- Navigate to window below
    vim.keymap.set('t', '<C-k>', [[<Cmd>wincmd k<CR>]], opts)  -- Navigate to window above
    vim.keymap.set('t', '<C-l>', [[<Cmd>wincmd l<CR>]], opts)  -- Navigate to right window

    -- Add resize controls while in terminal
    vim.keymap.set('t', '<C-Up>', [[<Cmd>resize +2<CR>]], opts)     -- Make terminal taller
    vim.keymap.set('t', '<C-Down>', [[<Cmd>resize -2<CR>]], opts)   -- Make terminal shorter
end

-- Apply keymaps when terminal opens
vim.cmd('autocmd! TermOpen term://* lua set_terminal_keymaps()')

-- Basic keymaps
local keymap = vim.keymap.set
local opts = { noremap = true, silent = true }

-- Toggle terminal with explicit size
keymap("n", "<leader>tt", "<cmd>ToggleTerm size=15<CR>", opts)
keymap("n", "<c-\\>", "<cmd>ToggleTerm size=15<CR>", opts)  -- Override the default mapping

-- Resize terminal from normal mode (when terminal is visible)
keymap("n", "<leader>t+", "<cmd>resize +5<CR>", opts)  -- Make terminal bigger
keymap("n", "<leader>t-", "<cmd>resize -5<CR>", opts)  -- Make terminal smaller
keymap("n", "<leader>t=", "<cmd>resize 15<CR>", opts)   -- Reset to default size

-- Open multiple terminal instances if needed
keymap("n", "<leader>t2", "<cmd>2ToggleTerm size=15<CR>", opts)
keymap("n", "<leader>t3", "<cmd>3ToggleTerm size=15<CR>", opts)

