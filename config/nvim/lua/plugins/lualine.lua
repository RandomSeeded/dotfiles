-- plugins/lualine.lua
-- Restyle LazyVim's built-in sidekick/Copilot statusline component (lualine_x).
-- The stock version colors by the server's reported status — but the copilot
-- server never reports busy during NES requests (measured), so it sat on one
-- color forever. Instead we derive state client-side from sidekick itself:
--   dim 󰚩    = idle/ready (signed in, nothing happening)
--   orange 󰚩 = NES request in flight
--   green 󰚩  = suggestion available -> <Tab> to jump/apply
--   red 󰚩    = copilot error state
-- Also bumps the statusline refresh timer (1000ms stock) so short-lived states
-- actually render. Glyph is nf-md-robot U+F06A9, byte-escaped so it can't be
-- silently dropped by editors/copy-paste.
local ROBOT = "\243\176\154\169 "

local function nes_state()
  local nes = package.loaded["sidekick.nes"]
  if nes and #nes._edits > 0 then
    return "suggestion"
  end
  if nes and next(nes._requests) then
    return "busy"
  end
  local status = require("sidekick.status").get()
  if status and status.kind == "Error" then
    return "error"
  end
  return status and "idle" or nil
end

local COLORS = {
  suggestion = "DiagnosticOk",
  busy = "DiagnosticWarn",
  error = "DiagnosticError",
  idle = "Comment",
}

return {
  {
    "nvim-lualine/lualine.nvim",
    opts = function(_, opts)
      -- refresh fast enough to catch the in-flight state (stock: 1000ms)
      opts.options = opts.options or {}
      opts.options.refresh = vim.tbl_deep_extend("force", opts.options.refresh or {}, { statusline = 100 })

      for _, comp in ipairs(opts.sections and opts.sections.lualine_x or {}) do
        if type(comp) == "table" and type(comp[1]) == "function" then
          local src = (debug.getinfo(comp[1], "S").source or "")
          if src:find("extras/ai/sidekick", 1, true) then
            local ok, rendered = pcall(comp[1])
            -- two components share that source: the CLI counter (always returns
            -- a string starting with U+EE0D "") and the LSP status (returns a
            -- state glyph or nil). Only replace the LSP status one.
            local is_cli = ok and type(rendered) == "string" and rendered:sub(1, 3) == "\238\184\141"
            if not is_cli then
              comp[1] = function()
                return nes_state() and ROBOT
              end
              comp.color = function()
                local hl = COLORS[nes_state() or "idle"]
                return { fg = Snacks.util.color(hl) or Snacks.util.color("Comment") }
              end
              -- keep the original cond (hides the icon in non-copilot buffers)
            end
          end
        end
      end
    end,
  },
}
