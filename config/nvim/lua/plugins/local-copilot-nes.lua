-- local-copilot-nes — route sidekick.nvim's Next-Edit-Suggestions to a local model.
--
-- Pulled + built automatically by lazy.nvim (see the plugin spec below), so it
-- travels with this nvim config — no separate project checkout to migrate. lazy
-- clones RandomSeeded/local-copilot-nes and runs `go build` on install/update.
-- Requires a local llama-server (or any OpenAI-compatible endpoint) serving a
-- next-edit model — see the project README.
--
-- STATUS: DISABLED — using real GitHub Copilot NES instead (see plugins/sidekick.lua;
-- the account's NES entitlement activated 2026-07-05). Set ENABLED = true to switch
-- back to the local-model backend (needs a local model endpoint serving).
--
-- What this does when ENABLED:
--   1. Pulls + builds the server via lazy.nvim, registers it as an LSP server.
--   2. Overrides sidekick's get_client so NES requests route to OUR server rather
--      than the copilot-language-server "copilot" client.

local ENABLED = false

local SERVER_NAME = "local-copilot-nes"

-- When disabled, do nothing: sidekick uses the real `copilot` client (GitHub
-- Copilot NES). Nothing below runs — the repo isn't even cloned by lazy.
if not ENABLED then
  return {}
end

-- 2. Route sidekick NES to our server (load-order-safe: patch once sidekick exists).
vim.api.nvim_create_autocmd("User", {
  pattern = "VeryLazy",
  callback = function()
    local ok, C = pcall(require, "sidekick.config")
    if not ok then
      return
    end
    C.get_client = function(buf)
      return vim.lsp.get_clients({ bufnr = buf or 0, name = SERVER_NAME })[1]
    end
  end,
})

return {
  -- Pull + build the local NES server from its repo (lazy runs `build` on install/update).
  {
    "RandomSeeded/local-copilot-nes",
    lazy = false,
    build = "go build -o bin/local-copilot-nes ./cmd/local-copilot-nes",
    config = function(plugin)
      -- 1. Register + enable the LSP server (nvim 0.11+ API), pointing at the
      --    binary lazy just built inside the plugin's install dir.
      vim.lsp.config(SERVER_NAME, {
        cmd = { plugin.dir .. "/bin/local-copilot-nes" },
        filetypes = { "python", "lua", "go", "javascript", "typescript", "javascriptreact", "typescriptreact", "cs" },
        root_markers = { ".git", "go.mod", "pyproject.toml", "package.json" },
      })
      vim.lsp.enable(SERVER_NAME)
    end,
  },
  -- Keep sidekick NES enabled (also set in plugins/sidekick.lua).
  {
    "folke/sidekick.nvim",
    opts = { nes = { enabled = true } },
  },
}
