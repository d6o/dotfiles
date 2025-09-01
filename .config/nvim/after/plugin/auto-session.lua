local status_ok, auto_session = pcall(require, "auto-session")
if not status_ok then
  return
end

auto_session.setup({
  log_level = "error",
  auto_session_enable_last_session = false,
  auto_session_root_dir = vim.fn.stdpath("data") .. "/sessions/",
  auto_session_enabled = true,
  auto_save_enabled = true,
  auto_restore_enabled = true,
  auto_session_suppress_dirs = { "/", "/tmp" },
  auto_session_use_git_branch = true,
  
  -- Save nvim-tree state before saving session
  pre_save_cmds = {
    function()
      -- Save whether nvim-tree was open
      local nvim_tree_api = require("nvim-tree.api")
      vim.g.nvim_tree_was_open = nvim_tree_api.tree.is_visible()
      
      -- Close nvim-tree before saving (it doesn't restore well from session)
      if vim.g.nvim_tree_was_open then
        nvim_tree_api.tree.close()
      end
      
      -- Clean up unnamed buffers
      for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].modified then
          local name = vim.api.nvim_buf_get_name(buf)
          if name == "" then
            vim.api.nvim_buf_delete(buf, { force = true })
          end
        end
      end
    end
  },
  
  -- Restore nvim-tree after loading session
  post_restore_cmds = {
    function()
      -- Restore nvim-tree if it was open
      vim.defer_fn(function()
        if vim.g.nvim_tree_was_open then
          require("nvim-tree.api").tree.open()
        end
        
        -- Clean up empty buffers
        for _, buf in ipairs(vim.api.nvim_list_bufs()) do
          local name = vim.api.nvim_buf_get_name(buf)
          if name == "" and vim.api.nvim_buf_line_count(buf) <= 1 then
            local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
            if #lines == 1 and lines[1] == "" then
              pcall(vim.api.nvim_buf_delete, buf, { force = true })
            end
          end
        end
      end, 50)  -- Small delay to ensure everything is loaded
    end
  },
})

-- Better sessionoptions
vim.o.sessionoptions = "buffers,curdir,tabpages,winsize,help,globals,skiprtp,folds"

-- Keymaps
local keymap = vim.keymap.set
local opts = { noremap = true, silent = true }

keymap("n", "<leader>ss", "<cmd>SessionSave<CR>", opts)
keymap("n", "<leader>sr", "<cmd>SessionRestore<CR>", opts)
keymap("n", "<leader>sd", "<cmd>SessionDelete<CR>", opts)

-- Optional: Always open nvim-tree on session restore (if you want it ALWAYS open)
vim.api.nvim_create_autocmd("SessionLoadPost", {
  callback = function()
    vim.defer_fn(function()
      require("nvim-tree.api").tree.open()
    end, 0)
  end,
})
