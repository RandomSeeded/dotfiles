-- Test harness for claude_follow core logic.
-- Run: nvim --headless -u NONE -l ~/.config/nvim/lua/claude_follow_test.lua

-- Bootstrap: add config lua dir to package.path
local config_lua = vim.fn.expand("~/.config/nvim/lua")
package.path = config_lua .. "/?.lua;" .. package.path

local M = require("claude_follow")

local pass, fail = 0, 0

local function ok(cond, msg)
  if cond then
    pass = pass + 1
    print("PASS  " .. msg)
  else
    fail = fail + 1
    print("FAIL  " .. msg)
  end
end

local function eq(got, expected, msg)
  if got == expected then
    pass = pass + 1
    print("PASS  " .. msg)
  else
    fail = fail + 1
    print("FAIL  " .. msg)
    print("      expected: " .. tostring(expected))
    print("      got:      " .. tostring(got))
  end
end

-- ── find_root ────────────────────────────────────────────────────────────────

-- git repo: should return the jobhunt repo root
local jobhunt_file = vim.fn.expand("~/Projects/jobhunt/src/main.ts")
local jobhunt_root = M.find_root(jobhunt_file)
ok(jobhunt_root:find("jobhunt") ~= nil, "find_root: git repo returns jobhunt root (got: " .. jobhunt_root .. ")")

-- ~/.claude dir: no git, no markers, under $HOME → $HOME child
local claude_file = vim.fn.expand("~/.claude/skills/foo.lua")
local claude_root = M.find_root(claude_file)
eq(claude_root, vim.fn.expand("~/.claude"), "find_root: ~/.claude/skills/foo.lua → ~/.claude")

-- file directly in $HOME → parent dir fallback
local home_file = vim.fn.expand("~/somefile.txt")
local home_root = M.find_root(home_file)
eq(home_root, vim.fn.expand("~"), "find_root: ~/somefile.txt → ~ (parent fallback)")

-- ── record_file & ordering ───────────────────────────────────────────────────

local state = {}

-- Use a real path that will resolve to a known root
local root_a = "/tmp"
state[root_a] = {}

-- Manually insert with controlled mtimes to test ordering
table.insert(state[root_a], { file = "/tmp/old.lua", mtime = 100 })
table.insert(state[root_a], { file = "/tmp/newer.lua", mtime = 200 })
table.sort(state[root_a], function(a, b) return a.mtime > b.mtime end)

eq(state[root_a][1].file, "/tmp/newer.lua", "record ordering: most recent first")
eq(state[root_a][2].file, "/tmp/old.lua",   "record ordering: oldest last")

-- Update existing entry bumps mtime
state[root_a][2].mtime = 999
table.sort(state[root_a], function(a, b) return a.mtime > b.mtime end)
eq(state[root_a][1].file, "/tmp/old.lua", "record ordering: updated entry bubbles to top")

-- ── state save/load roundtrip ─────────────────────────────────────────────────

local test_state = {
  ["/tmp/proj-a"] = {
    { file = "/tmp/proj-a/foo.lua", mtime = 1000 },
    { file = "/tmp/proj-a/bar.lua", mtime = 900 },
  },
}

local tmp_path = vim.fn.tempname() .. ".json"

-- Inline save/load with temp path
local function save_tmp(s)
  local ok2, json = pcall(vim.json.encode, s)
  if not ok2 then return end
  vim.fn.writefile({ json }, tmp_path)
end

local function load_tmp()
  if vim.fn.filereadable(tmp_path) == 0 then return {} end
  local data = vim.fn.readfile(tmp_path)
  local ok2, parsed = pcall(vim.json.decode, table.concat(data, "\n"))
  if not ok2 then return {} end
  return parsed
end

save_tmp(test_state)
local loaded = load_tmp()

ok(loaded["/tmp/proj-a"] ~= nil, "roundtrip: root key preserved")
eq(#loaded["/tmp/proj-a"], 2,    "roundtrip: entry count preserved")
eq(loaded["/tmp/proj-a"][1].file, "/tmp/proj-a/foo.lua", "roundtrip: file path preserved")
eq(loaded["/tmp/proj-a"][1].mtime, 1000, "roundtrip: mtime preserved")

vim.fn.delete(tmp_path)

-- ── root_mtime ────────────────────────────────────────────────────────────────

local entries = {
  { file = "/a", mtime = 500 },
  { file = "/b", mtime = 1500 },
  { file = "/c", mtime = 300 },
}
eq(M.root_mtime(entries), 1500, "root_mtime: returns max mtime")

-- Recording is no longer done in nvim (a Claude Code PostToolUse hook writes the
-- state file); nvim only reads. See claude_follow_record_test.py for record/root tests.

-- ── summary ──────────────────────────────────────────────────────────────────

print(string.format("\n%d passed, %d failed", pass, fail))
if fail > 0 then os.exit(1) end
