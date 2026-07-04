-- plugins/csharp.lua
-- Switch C# from OmniSharp to the Roslyn language server (seblyng/roslyn.nvim).
--
-- Why: OmniSharp is effectively unmaintained for .NET 9/10 and was failing here.
-- Launched from ~ with no .git in the tree, its root fell back to the home dir,
-- so it tried to glob all of ~, hit a recursive ~/Library/Trial symlink loop
-- (PathTooLongException), and every project system crashed during init. No project
-- ever loaded into the Roslyn workspace, so goto-definition / references found
-- nothing. Roslyn LS is the engine VS Code's C# Dev Kit uses and is solid on .NET 10.
--
-- The rest of LazyVim's dotnet extra (treesitter, csharpier, netcoredbg/DAP, neotest)
-- is server-agnostic and stays — we're only swapping the LSP.

return {
  -- 1. The new C# LSP. Lazy-loads on .cs files; LazyVim calls require("roslyn").setup(opts).
  {
    "seblyng/roslyn.nvim",
    ft = "cs",
    opts = {},
  },

  -- 2. Make sure the Roslyn server binary is installed via Mason. roslyn.nvim
  --    auto-detects $MASON/bin/roslyn-language-server (see roslyn/utils.lua).
  {
    "mason-org/mason.nvim",
    opts = { ensure_installed = { "roslyn-language-server" } },
  },

  -- 3. Turn OmniSharp off so the two C# servers don't fight. enabled=false makes
  --    LazyVim skip its setup entirely, which also drops the dotnet extra's
  --    gd -> omnisharp_extended remap (it only attaches to the omnisharp client).
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        omnisharp = { enabled = false },
        -- nvim-lspconfig also ships a `roslyn_ls` server, which mason-lspconfig
        -- auto-enables once the mason package is installed. That would attach a
        -- SECOND Roslyn process alongside roslyn.nvim's own `roslyn` client.
        -- Disable it so only roslyn.nvim manages the server.
        roslyn_ls = { enabled = false },
      },
    },
  },
}
