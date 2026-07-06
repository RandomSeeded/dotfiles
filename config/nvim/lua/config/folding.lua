-- Interface-overview folding.
--
-- Folds are created (treesitter) and open by default (see config/options.lua:
-- foldlevel/foldlevelstart = 99). This module adds a single toggle, `zi`, that
-- collapses the buffer down to its "interface" -- the signatures a reader cares
-- about -- and toggles back to fully open.
--
-- 'foldlevel' closes every fold DEEPER than the number. The depth of "the
-- interface" differs by language, so we keep a per-filetype table plus a
-- default. Lower number = more collapsed.

-- How deep to keep OPEN when collapsing (folds deeper than this close).
local interface_level = {
  -- Flat languages: top-level funcs -> one line each.
  go = 0,
  rust = 0,
  lua = 0,
  python = 0,
  -- Nested: keep namespace/class header open, collapse the methods.
  cs = 2,
  java = 2,
  -- Module -> class -> method.
  typescript = 1,
  typescriptreact = 1,
  javascript = 1,
  javascriptreact = 1,
}

-- Fallback for any filetype not listed above.
local default_level = 1

-- Treated as "fully open" -- matches foldlevel/foldlevelstart in options.lua.
local open_level = 99

vim.keymap.set("n", "zi", function()
  local target = interface_level[vim.bo.filetype] or default_level
  -- If we're more open than the overview, collapse to it; otherwise re-open.
  vim.wo.foldlevel = (vim.wo.foldlevel > target) and target or open_level
end, { desc = "Toggle interface overview folds" })
