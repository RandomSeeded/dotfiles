-- plugins/editor.lua
-- General editor plugins translated from LunarVim config.lua

return {

  -- ─── tpope essentials ────────────────────────────────────────────
  { "tpope/vim-fugitive" }, -- Git commands (:Git, :Gdiff, etc.)
  { "tpope/vim-surround" }, -- cs, ds, ys motions for surrounding chars
  { "tpope/vim-abolish" }, -- Smart substitution, case-coercion (crs, crm, etc.)

  -- ─── Colorscheme ─────────────────────────────────────────────────
  {
    "sainnhe/sonokai",
    lazy = false,
    priority = 1000, -- load before everything else
    config = function()
      vim.g.sonokai_style = "shusia"
      vim.cmd.colorscheme("sonokai")
    end,
  },

  -- ─── Telescope tweaks ────────────────────────────────────────────
  -- Replaces lvim.builtin.telescope.defaults.*
  {
    "nvim-telescope/telescope.nvim",
    opts = {
      defaults = {
        layout_strategy = "vertical",
        layout_config = {
          width = 0.75,
          height = 0.75,
          preview_height = 0.5,
        },
        path_display = { truncate = 4 },
      },
    },
  },

  -- ─── NvimTree width ──────────────────────────────────────────────
  -- Replaces lvim.builtin.nvimtree.setup.view.width = 60
  {
    "nvim-tree/nvim-tree.lua",
    opts = {
      view = { width = 60 },
    },
  },

  -- ─── Disable bufferline ──────────────────────────────────────────
  -- Replaces lvim.builtin.bufferline.active = false
  { "akinsho/bufferline.nvim", enabled = false },

  -- ─── Disable indent guides ───────────────────────────────────────
  -- Replaces lvim.builtin.indentlines.active = false
  { "lukas-reineke/indent-blankline.nvim", enabled = false },

  -- ─── Formatter: csharpier for C# ─────────────────────────────────
  -- Replaces: formatters.setup { { name = "csharpier", filetypes = { "cs" } } }
  -- conform.nvim is LazyVim's formatter layer (replaces null-ls)
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        cs = { "csharpier" },
      },
    },
  },

  -- ─── Treesitter: disable indent ──────────────────────────────────
  -- Replaces lvim.builtin.treesitter.indent = { enable = false }
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      indent = { enable = false },
    },
  },
  -- Disable some plugins included as part of LazyVim around replacing functionality or visual 'improvements'
  { "folke/flash.nvim", enabled = false },
  { "folke/noice.nvim", enabled = false },
  {
    "folke/snacks.nvim",
    opts = {
      scroll = { enabled = false },
      -- Show only the current block's scope line (│ from top to bottom of the
      -- block your cursor is in) -- no always-on per-level indent guides.
      indent = {
        enabled = true,
        indent = { enabled = false }, -- suppress the per-level guides (the noise)
        scope = { enabled = true, char = "│" }, -- the block-extent line
        animate = { enabled = false }, -- flip to true for the sweep animation
      },
      picker = {
        sources = {
          files = { follow = true },
        },
        actions = {
          find_from_home = function(picker)
            picker:close()
            vim.schedule(function()
              Snacks.picker.files({ cwd = vim.fn.expand("~") })
            end)
          end,
        },
        win = {
          input = {
            keys = {
              ["<C-h>"] = { "toggle_hidden", mode = { "i", "n" } },
              ["<C-i>"] = { "toggle_ignored", mode = { "i", "n" } },
              ["<C-\\>"] = { "find_from_home", mode = { "i", "n" } },
            },
          },
        },
      },
      dashboard = {
        preset = {
          header = [[
███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗
████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║
██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║
██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║
██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║
╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝
]],
        },
      },
      -- marks = { enabled = false },
    },
  },
  -- Disable function parameter automatically being provided on autocomplete
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        vtsls = {
          -- Force full-document sync (change=1) instead of incremental (change=2).
          -- Works around an nvim 0.12 crash in vim/lsp/sync.lua compute_start_range
          -- (assert(prev_lines[firstline])) on certain edits. See neovim/neovim#33224.
          -- Perf cost is negligible for normal-sized files; remove this line to revert.
          flags = { allow_incremental_sync = false },
          settings = {
            complete_function_calls = false,
            typescript = {
              suggest = { completeFunctionCalls = false },
            },
            javascript = {
              suggest = { completeFunctionCalls = false },
            },
          },
        },
      },
    },
  },
  -- Disable gitsigns
  { "lewis6991/gitsigns.nvim", enabled = false },
  -- { "github/copilot.vim" },
  {
    "zbirenbaum/copilot.lua",
    -- DISABLED for the sidekick-canonical setup: NES now uses nvim-lspconfig's
    -- copilot-language-server (see plugins/sidekick.lua). Running copilot.lua too would
    -- start a SECOND copilot server and race on auth.db. Re-enable (set enabled=true, or
    -- delete this line) to get inline ghost text back; or use native vim.lsp.inline_completion.
    enabled = false,
    cmd = "Copilot",
    event = "InsertEnter",
    config = function()
      require("copilot").setup({
        suggestion = {
          enabled = true,
          auto_trigger = true,
          keymap = {
            -- <Tab> accept is handled in the blink.cmp keymap below, since
            -- blink owns the insert-mode <Tab> mapping and would shadow this.
            accept = false,
            dismiss = "<C-]>",
            next = "<M-]>",
            prev = "<M-[>",
          },
        },
        panel = { enabled = false },
        -- Don't start a separate copilot LSP — sidekick already manages it
        server_opts_overrides = {},
      })
    end,
  },
  -- blink.cmp tweaks
  {
    "saghen/blink.cmp",
    opts = {
      -- <Tab>: accept a visible Copilot suggestion first, otherwise fall
      -- through to blink's normal snippet-jump / fallback behavior.
      keymap = {
        ["<Tab>"] = {
          function()
            local ok, suggestion = pcall(require, "copilot.suggestion")
            if ok and suggestion.is_visible() then
              suggestion.accept()
              return true
            end
          end,
          "snippet_forward",
          "fallback",
        },
        -- <CR> no longer accepts completions (the `enter` preset made it
        -- overwrite hand-typed text when starting a new line). It now just
        -- inserts a newline. Accept with <C-y> (preset's select_and_accept).
        ["<CR>"] = { "fallback" },
      },
      completion = {
        -- Disable the autocomplete popup in markdown (manual <C-Space> still works)
        menu = {
          auto_show = function()
            return vim.bo.filetype ~= "markdown"
          end,
        },
      },
    },
  },
}
