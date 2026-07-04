-- plugins/sidekick.lua

return {
  -- Prevent a SECOND copilot-language-server from starting.
  -- copilot.lua already spawns its own copilot server (node) for inline suggestions.
  -- Separately, the mason copilot-language-server gets auto-enabled via lspconfig,
  -- giving a duplicate. Two servers open the same SQLite DBs
  -- (~/.config/github-copilot/auth.db + the tfidf index) and race for the lock,
  -- producing "database is locked" -> tfidfWorker crash -> "copilot exit code 143".
  -- Disabling it here guarantees only copilot.lua's single server runs.
  -- (Verified: removing this brings back 2 copilot clients even with NES off.)
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        copilot = { enabled = false },
      },
    },
  },
  {
    "folke/sidekick.nvim",
    -- NES (Next Edit Suggestions) is powered by a LOCAL model via local-copilot-nes
    -- (see plugins/local-copilot-nes.lua), which registers our LSP server and routes
    -- sidekick's NES client to it. To revert: set this back to false and delete
    -- plugins/local-copilot-nes.lua.
    opts = { nes = { enabled = true } },
    keys = {
      -- Tab: jump to / apply next edit suggestion, fallback to normal tab
      {
        "<tab>",
        function()
          if not require("sidekick").nes_jump_or_apply() then
            return "<Tab>"
          end
        end,
        expr = true,
        desc = "Goto/Apply Next Edit Suggestion",
      },
      -- Toggle the AI CLI panel
      {
        "<c-.>",
        function()
          require("sidekick.cli").focus()
        end,
        desc = "Sidekick Focus",
        mode = { "n", "t", "i", "x" },
      },
      {
        "<leader>aa",
        function()
          require("sidekick.cli").toggle()
        end,
        desc = "Sidekick Toggle CLI",
      },
      {
        "<leader>as",
        function()
          require("sidekick.cli").select()
        end,
        desc = "Sidekick Select CLI",
      },
      {
        "<leader>ad",
        function()
          require("sidekick.cli").close()
        end,
        desc = "Sidekick Detach",
      },
      -- Send context to the CLI
      {
        "<leader>at",
        function()
          require("sidekick.cli").send({ msg = "{this}" })
        end,
        mode = { "x", "n" },
        desc = "Send This",
      },
      {
        "<leader>av",
        function()
          require("sidekick.cli").send({ msg = "{selection}" })
        end,
        mode = { "x" },
        desc = "Send Selection",
      },
      {
        "<leader>ap",
        function()
          require("sidekick.cli").prompt()
        end,
        mode = { "n", "x" },
        desc = "Sidekick Prompt",
      },
      -- Send File moved from <leader>af (freed for claude-follow picker)
      {
        "<leader>aF",
        function()
          require("sidekick.cli").send({ msg = "{file}" })
        end,
        desc = "Send File",
      },
      -- Disable LazyVim extra's <leader>af (Send File) so claude-follow can own it
      { "<leader>af", false },
    },
  },
}
