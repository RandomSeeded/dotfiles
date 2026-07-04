-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Close quickfix window (was \x)
vim.keymap.set("n", "\\x", ":ccl<cr>", { desc = "Close quickfix" })

-- Clear search highlight (was \q)
vim.keymap.set("n", "\\q", ":nohl<cr>", { desc = "Clear highlight" })

-- 'c' should not yank to clipboard (black hole register)
-- Same behaviour as: lvim.keys.normal_mode['c'] = '"_c'
vim.keymap.set("n", "c", '"_c', { desc = "Change without yanking" })

-- Search for word under cursor with Telescope
-- (was lvim.builtin.which_key.mappings["ss"])
vim.keymap.set("n", "<leader>ss", "<cmd>Telescope grep_string<cr>", { desc = "Search word under cursor" })

-- Restart LSP
-- (was lvim.builtin.which_key.mappings["lx"])
vim.keymap.set("n", "<leader>lx", "<cmd>LspRestart<cr>", { desc = "Restart LSP" })

-- Format with longer timeout (2s instead of default)
-- (was lvim.builtin.which_key.mappings["l"]["f"])
vim.keymap.set("n", "<leader>lf", function()
  vim.lsp.buf.format({ timeout_ms = 2000 })
end, { desc = "Format" })

-- Jump to next diagnostic
vim.keymap.set("n", "<leader>lj", vim.diagnostic.goto_next, { desc = "Next Diagnostic" })
vim.keymap.set("n", "<leader>lk", vim.diagnostic.goto_prev, { desc = "Prev Diagnostic" })

-- Toggle all AI features (copilot inline + NES)
-- vim.keymap.set("n", "<leader>ad", function()
--   -- Toggle copilot.lua inline suggestions
--   require("copilot.suggestion").toggle_auto_trigger()
--
--   -- Toggle sidekick NES
--   local nes = require("sidekick.nes")
--   if nes.enabled then
--     nes.disable()
--     vim.notify("AI disabled", vim.log.levels.INFO)
--   else
--     nes.enable()
--     vim.notify("AI enabled", vim.log.levels.INFO)
--   end
-- end, { desc = "Toggle AI" })
local ai_enabled = true
vim.keymap.set("n", "<leader>ad", function()
  if ai_enabled then
    require("copilot.suggestion").dismiss()
    require("copilot.command").disable()
    local nes = require("sidekick.nes")
    if nes.enabled then
      nes.disable()
    end
    vim.notify("AI disabled", vim.log.levels.INFO)
  else
    require("copilot.command").enable()
    local nes = require("sidekick.nes")
    if not nes.enabled then
      nes.enable()
    end
    vim.notify("AI enabled", vim.log.levels.INFO)
  end
  ai_enabled = not ai_enabled
end, { desc = "Toggle AI" })
