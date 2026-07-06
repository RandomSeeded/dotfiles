-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

vim.g.root_spec = { ".git", "lsp", "cwd" }

vim.opt.wrap = true -- wrap long lines
vim.opt.autoread = true -- reload files changed outside nvim
vim.opt.timeoutlen = 1000 -- play nicely with tmux (ms to wait for mapped sequence)
vim.opt.ttimeoutlen = 0 -- no delay on key code sequences

-- Folding (treesitter-based, same as your LunarVim setup)
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.opt.foldenable = true
vim.opt.foldlevel = 99 -- open by default
vim.opt.foldlevelstart = 99 -- files open fully unfolded
vim.opt.foldnestmax = 3
vim.opt.foldminlines = 1
-- vim.wo.fillchars = "fold: "

-- Fold display
vim.opt.foldtext = "" -- use the actual first line of the fold as the label
vim.opt.fillchars = {
  fold = "─", -- fills the rest of the line with dashes
  foldopen = "▾",
  foldclose = "▸",
  foldsep = "│",
}

-- Don't render tabs as visible markers (default was tab:"> "); keep trailing/nbsp hints.
vim.opt.listchars = { tab = "  ", trail = "-", nbsp = "+" }

-- Absolute line numbers only
vim.opt.relativenumber = false

-- Disable inline type hints / virtual text
vim.diagnostic.config({
  virtual_text = false,
  virtual_lines = false,
})

-- NvimTree sidebar width (replaces lvim.builtin.nvimtree.setup.view.width = 60)
-- This is set here as a global so the plugin spec can pick it up,
-- but the canonical place is in plugins/nvimtree.lua (see that file).
vim.g.nvimtree_width = 60

-- Disable marks from appearing in the status column via snacks
vim.opt.statuscolumn = ""

-- Work around the nvim 0.12 incremental-sync crash (neovim#33224): vim/lsp/sync.lua
-- compute_start_range asserts on certain buffer edits, crashing on every keystroke.
-- The fix is to force full-document sync (allow_incremental_sync = false) on EVERY
-- client. We patch the lowest client-creation funnel (vim.lsp.client.create) so it
-- applies no matter how a client is started — vim.lsp.config("*") only covers the
-- enable/config path and was missing clients started directly via vim.lsp.start
-- (e.g. copilot.lua). The flag must be set before the client is created, because
-- changetracking.init() reads it once at didOpen (client.lua:1133), before LspAttach.
-- Perf cost of full sync is negligible for normal-sized files.
do
  local lsp_client = require("vim.lsp.client")
  local orig_create = lsp_client.create
  lsp_client.create = function(config)
    config = config or {}
    config.flags = config.flags or {}
    -- EXCEPTION: copilot must keep incremental sync. With full-document sync, every
    -- didChange is a whole-file snapshot with no edit ranges, so the server's Local
    -- Diff Tracker never registers "recent edits" and NES (copilotInlineEdit) returns
    -- {edits={}} forever WITHOUT even calling the model. Verified 2026-07-05: same
    -- server+account+edits — incremental → NES edit returned; full sync → always empty.
    -- Trade-off: the nvim#33224 crash could resurface on the copilot client; if it
    -- does, prefer updating nvim over re-adding full sync here (that kills NES).
    if config.flags.allow_incremental_sync == nil and config.name ~= "copilot" then
      config.flags.allow_incremental_sync = false
    end
    return orig_create(config)
  end
end

-- Disable inlay hints globally
-- vim.lsp.inlay_hint.enable(false)
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    vim.lsp.inlay_hint.enable(false, { bufnr = args.buf })
  end,
})

-- Deletions/changes don't copy to clipboard
vim.opt.clipboard = ""

-- Other programs (e.g. claude) modify our files - reload when they do
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI" }, {
  callback = function()
    if vim.fn.mode() ~= "c" then
      vim.cmd("checktime")
    end
  end,
})
