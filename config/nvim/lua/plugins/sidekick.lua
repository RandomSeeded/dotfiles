-- plugins/sidekick.lua

return {
  -- Prevent a SECOND copilot-language-server from starting.
  -- copilot.lua already spawns its own copilot server (node) for inline suggestions.
  -- Separately, the mason copilot-language-server gets auto-enabled via lspconfig,
  -- giving a duplicate. Two servers open the same SQLite DBs
  -- (~/.config/github-copilot/auth.db + the tfidf index) and race for the lock,
  -- producing "database is locked" -> tfidfWorker crash -> "copilot exit code 143".
  -- SIDEKICK-CANONICAL SETUP: sidekick's README wants the copilot-language-server
  -- enabled via nvim-lspconfig (`vim.lsp.enable("copilot")`) — that config provides
  -- :LspCopilotSignIn and is the client sidekick attaches to. copilot.lua's OWN
  -- bundled server is disabled in plugins/editor.lua so exactly ONE copilot server
  -- runs (no auth.db lock race). Revert: set enabled=false here + re-enable copilot.lua.
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        copilot = { enabled = true },
      },
    },
  },
  {
    "folke/sidekick.nvim",
    -- NES (Next Edit Suggestions) is powered by GitHub Copilot via the
    -- copilot-language-server enabled above (nvim-lspconfig `copilot`). The local
    -- NES alternative is parked in plugins/local-copilot-nes.lua (ENABLED=false).
    -- clear.esc=false: don't dismiss a pending/visible suggestion on <Esc> —
    -- the natural flow is edit-in-insert -> Esc -> suggestion appears, and habitual
    -- extra Esc presses were nuking it. Typing again (TextChangedI/InsertEnter)
    -- still clears stale suggestions.
    opts = { nes = { enabled = true, clear = { esc = false } } },
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
          -- Auto-run the selected prompt. sidekick's default prompt callback
          -- calls send({ text }) WITHOUT submit, which only stuffs text into the
          -- CLI pane -- you'd then have to switch panes and press Enter yourself.
          -- Passing submit = true makes sidekick fire `tmux send-keys Enter` at
          -- the target pane remotely, so the prompt actually runs in place.
          require("sidekick.cli").prompt({
            cb = function(_, text)
              if text then
                require("sidekick.cli").send({ text = text, submit = true })
              end
            end,
          })
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
