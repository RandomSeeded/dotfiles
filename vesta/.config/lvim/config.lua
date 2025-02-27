-- Read the docs: https://www.lunarvim.org/docs/configuration
-- Video Tutorials: https://www.youtube.com/watch?v=sFA9kX-Ud_c&list=PLhoH5vyxr6QqGu0i7tt_XoVK9v-KvZ3m6
-- Forum: https://www.reddit.com/r/lunarvim/
-- Discord: https://discord.com/invite/Xb9B4Ny


-- Change nerdtree default width
vim.g.NERDTreeWinSize = 31



lvim.plugins = {
  { "jmederosalvarado/roslyn.nvim" },
  { "tpope/vim-fugitive" },
  { "tpope/vim-surround" },
  { "tpope/vim-abolish" },
  { "sainnhe/sonokai" },
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    config = function()
      require("copilot").setup({})
    end,
  },
  {
    "zbirenbaum/copilot-cmp",
    config = function()
      require("copilot_cmp").setup({
        suggestion = { enabled = false },
        panel = { enabled = false }
      })
    end
  },
    {
    "CopilotC-Nvim/CopilotChat.nvim",
    branch = "canary",
    dependencies = {
      { "zbirenbaum/copilot.lua" }, -- or github/copilot.vim
      { "nvim-lua/plenary.nvim" }, -- for curl, log wrapper
    },
    build = "make tiktoken", -- Only on MacOS or Linux
    opts = {
      debug = true, -- Enable debugging
      -- See Configuration section for rest
    },
    -- See Commands section for default commands if you want to lazy load on them
  },
}

-- -- Below config is required to prevent copilot overriding Tab with a suggestion
-- -- when you're just trying to indent!
local has_words_before = function()
  if vim.api.nvim_buf_get_option(0, "buftype") == "prompt" then return false end
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  return col ~= 0 and vim.api.nvim_buf_get_text(0, line - 1, 0, line - 1, col, {})[1]:match("^%s*$") == nil
end
local on_tab = vim.schedule_wrap(function(fallback)
  local cmp = require("cmp")
  if cmp.visible() and has_words_before() then
    cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
  else
    fallback()
  end
end)
lvim.builtin.cmp.mapping["<Tab>"] = on_tab

--[[ vim.g.lightline = {
colorscheme = "sonokai"
} ]]
vim.g.sonokai_style = "shusia"
lvim.colorscheme = "sonokai"


require("roslyn").setup({
  dotnet_cmd = "dotnet",              -- this is the default
  roslyn_version = "4.8.0-3.23475.7", -- this is the default
  on_attach = require("lvim.lsp").common_on_attach,
  capabilities = lvim.lsp.capabilities
})

-- cclose quickfix
vim.keymap.set('n', '\\x', ':ccl<cr>')
vim.keymap.set('n', '\\q', ':nohl<cr>')

-- remove stupid bufferline - keep tabline aka file display
lvim.builtin.bufferline.active = false

-- play nicely with tmux
vim.opt.timeoutlen = 1000
vim.opt.ttimeoutlen = 0

vim.opt.wrap = true -- wrap lines

-- Cosmetic configuration for telescope - increase the size of the search area, include more of the filepath
lvim.builtin.telescope.defaults.layout_strategy = 'vertical'
lvim.builtin.telescope.defaults.layout_config = {
  width = 0.75, -- 0.90,
  height = 0.75,
  preview_height = 0.5,
}
lvim.builtin.telescope.defaults.path_display = { truncate = 4 }

-- search for word under cursor
lvim.builtin.which_key.mappings["ss"] = {
  "<cmd>Telescope grep_string<cr>", "cursor"
}
-- provide hotkey to restart LSP
lvim.builtin.which_key.mappings["lx"] = {
  "<cmd>LspRestart<cr>", "restart"
}
-- increase timeout for format
lvim.builtin.which_key.mappings["l"]["f"] = {
  function()
    require("lvim.lsp.utils").format { timeout_ms = 2000 }
  end,
  "Format",
}
-- copilot chat
lvim.builtin.which_key.mappings["z"] = {
  "<cmd>CopilotChatToggle<cr>", "copilot chat"
}

local linters = require "lvim.lsp.null-ls.linters"
local formatters = require "lvim.lsp.null-ls.formatters"
linters.setup {
  { name = "eslint_d", filetypes = { "typescript", "typescriptreact" } }
}
formatters.setup {
  { name = "csharpier", filetypes = { "cs" } }
}

vim.o.autoread = true

-- NOTE: must run :LvimCacheReset to cause changes here to take effect
-- DISABLED LSPs
vim.list_extend(lvim.lsp.automatic_configuration.skipped_servers, { "omnisharp", "csharp_ls" })
-- ENABLED LSPs
lvim.lsp.automatic_configuration.skipped_servers = vim.tbl_filter(function(server)
  return server ~= "roslyn"
  -- return server ~= "csharp_ls"
end, lvim.lsp.automatic_configuration.skipped_servers)

-- Don't cause change text to copy to the system clipboard
lvim.keys.normal_mode['c'] = '"_c'

-- Folding options
vim.opt.foldmethod = "expr"                     -- default is "normal"
vim.opt.foldexpr = "nvim_treesitter#foldexpr()" -- default is ""
vim.opt.foldenable = true                       -- if this option is true and fold method option is other than normal, every time a document is opened everything will be folded.
vim.wo.fillchars = "fold: "
vim.wo.foldnestmax = 3
vim.wo.foldminlines = 1
vim.wo.foldlevel = 1


-- give nerd-tree extra width
lvim.builtin.nvimtree.setup.view.width = 60

-- increase formatters timeout
-- lvim.lsp.null_ls.setup.timeout = 10000; --Doesnt work??


-- Copilot setup:
-- lvim.plugins = {
--     {
--         "zbirenbaum/copilot.lua",
--         cmd = "Copilot",
--         event = "InsertEnter",
--         config = function()
--             require("copilot").setup({})
--         end,
--     },
--
--     {
--         "zbirenbaum/copilot-cmp",
--         config = function()
--             require("copilot-cmp").setup({
--                 suggestion = { enabled = false },
--                 panel = { enabled = false }
--             })
--         end
--     }
-- }
