-- Claude Follow: browse files Claude Code has touched, grouped by project root.
--
-- Recording happens OUTSIDE nvim: a Claude Code PostToolUse hook
-- (~/.claude/hooks/claude_follow_record.py, wired in ~/.claude/settings.json)
-- appends edited files to ~/.local/share/nvim/claude-follow.json on every
-- Edit/Write/MultiEdit — independent of permission mode, and works for
-- background/agent sessions too. This file is purely the read-side picker.

local uv = vim.uv or vim.loop
local STATE_PATH = vim.fn.stdpath("data") .. "/claude-follow.json"
local FLASH_NS = vim.api.nvim_create_namespace("claude_follow_flash")
local FLASH_MS = 1500

local watch = {
  active = false,
  handle = nil,
  last_mtime = 0,
  tabpage = nil, -- dedicated watch tab
}

-- Return the watch tab's first window, creating the tab if needed.
-- Does not steal focus from the current tab.
local function watch_ensure_win()
  if watch.tabpage and vim.api.nvim_tabpage_is_valid(watch.tabpage) then
    return vim.api.nvim_tabpage_list_wins(watch.tabpage)[1]
  end
  local prev = vim.api.nvim_get_current_tabpage()
  vim.cmd("tabnew")
  watch.tabpage = vim.api.nvim_get_current_tabpage()
  vim.api.nvim_set_current_tabpage(prev)
  return vim.api.nvim_tabpage_list_wins(watch.tabpage)[1]
end

local function watch_open_entry(entry)
  if vim.fn.filereadable(entry.file) == 0 then return end
  local win = watch_ensure_win()
  vim.api.nvim_win_call(win, function()
    vim.cmd("edit " .. vim.fn.fnameescape(entry.file))
    if entry.line then
      local ok, _ = pcall(vim.api.nvim_win_set_cursor, 0, { entry.line, 0 })
      if ok then vim.cmd("normal! zz") end
      local bufnr = vim.api.nvim_get_current_buf()
      local last = entry.line_end or entry.line
      vim.highlight.range(bufnr, FLASH_NS, "Visual",
        { entry.line - 1, 0 }, { last - 1, -1 })
      vim.defer_fn(function()
        vim.api.nvim_buf_clear_namespace(bufnr, FLASH_NS, 0, -1)
      end, FLASH_MS)
    end
  end)
  local rel = vim.fn.fnamemodify(entry.file, ":~")
  local loc = entry.line and (":" .. entry.line) or ""
  if entry.line_end and entry.line_end ~= entry.line then
    loc = loc .. "-" .. entry.line_end
  end
  vim.notify("claude  " .. rel .. loc, vim.log.levels.INFO)
end

local function watch_check()
  local cf = require("claude_follow")
  local state = cf.load_state()
  local latest = cf.latest_entry(state)
  if latest and latest.mtime > watch.last_mtime then
    watch.last_mtime = latest.mtime
    watch_open_entry(latest)
  end
end

local function watch_stop()
  if watch.handle then
    watch.handle:stop()
    watch.handle = nil
  end
  watch.active = false
  vim.notify("claude-follow: watch off", vim.log.levels.INFO)
end

local function watch_toggle()
  if watch.active then
    watch_stop()
    return
  end

  -- Seed last_mtime from current state so enabling doesn't immediately jump.
  local cf = require("claude_follow")
  local latest = cf.latest_entry(cf.load_state())
  watch.last_mtime = latest and latest.mtime or 0

  -- Ensure the dedicated tab exists before starting the watcher.
  watch_ensure_win()

  local handle = uv.new_fs_event()
  handle:start(STATE_PATH, {}, vim.schedule_wrap(function(err, _, _)
    if err then return end
    watch_check()
  end))

  watch.handle = handle
  watch.active = true
  vim.notify("claude-follow: watch on (tab " .. vim.api.nvim_tabpage_get_number(watch.tabpage) .. ")", vim.log.levels.INFO)
end

local function open_picker()
  local cf = require("claude_follow")
  -- Fresh read every open: the hook writes this file from other processes,
  -- so an in-memory cache would go stale. Prune is in-memory only (never saved).
  local state = cf.load_state()
  cf.prune_state(state)

  -- Build sorted list of roots (most recently touched first)
  local roots = {}
  for root, entries in pairs(state) do
    table.insert(roots, {
      root = root,
      label = cf.root_label(root),
      mtime = cf.root_mtime(entries),
      entries = entries,
    })
  end
  table.sort(roots, function(a, b) return a.mtime > b.mtime end)

  if #roots == 0 then
    vim.notify("claude-follow: no files recorded yet", vim.log.levels.INFO)
    return
  end

  Snacks.picker({
    title = "Claude: Files by Project",
    items = (function()
      local items = {}
      for _, r in ipairs(roots) do
        local date = os.date("%Y-%m-%d %H:%M", r.mtime)
        table.insert(items, {
          text = r.label,
          root = r.root,
          entries = r.entries,
          date = date,
        })
      end
      return items
    end)(),
    format = function(item, _picker)
      return {
        { item.text, "Normal" },
        { "  " .. item.date, "Comment" },
      }
    end,
    preview = function(ctx)
      local item = ctx.item
      if not item then return end
      local lines = { "Files modified by Claude:", "" }
      for _, entry in ipairs(item.entries) do
        local rel = vim.fn.fnamemodify(entry.file, ":~")
        local date = os.date("%H:%M", entry.mtime)
        table.insert(lines, string.format("  %s  %s", rel, date))
      end
      ctx.preview:set_lines(lines)
    end,
    confirm = function(picker, item)
      picker:close()
      if not item then return end
      -- Open all files as tabs, land on most recent (first in list, sorted desc)
      for i = #item.entries, 1, -1 do
        local f = item.entries[i].file
        if vim.fn.filereadable(f) == 1 then
          vim.cmd("tabedit " .. vim.fn.fnameescape(f))
        end
      end
    end,
    layout = {
      preset = "default",
    },
  })
end

-- Host the keymap on snacks.nvim (already installed; provides Snacks.picker).
return {
  "folke/snacks.nvim",
  optional = true,
  keys = {
    {
      "<leader>af",
      open_picker,
      desc = "Follow: Claude files by project",
    },
    {
      "<leader>aw",
      watch_toggle,
      desc = "Follow: toggle live watch",
    },
  },
}
