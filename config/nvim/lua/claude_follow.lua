-- Core logic for claude-follow: read the set of files Claude Code has touched,
-- grouped by project root, for the picker. Recording is done OUT of nvim by a
-- Claude Code PostToolUse hook (~/.claude/hooks/claude_follow_record.py) which
-- writes the state file below. nvim is a read-only consumer here.
--
-- Pure logic (no picker, no I/O side effects beyond reading) so it can be
-- unit-tested headlessly.

local M = {}

local STATE_PATH = vim.fn.stdpath("data") .. "/claude-follow.json"

local PROJECT_MARKERS = {
  "package.json", "Cargo.toml", "pyproject.toml", "go.mod", ".envrc",
  "Makefile", "CMakeLists.txt", "mix.exs", ".project",
}

-- Find the project root for a given file path.
-- Priority: git root → project marker → $HOME child → parent dir
-- Mirrors claude_follow_record.py:find_root so display roots match recorded roots.
---@param file_path string
---@return string root
function M.find_root(file_path)
  local dir = vim.fn.fnamemodify(file_path, ":h")

  -- 1. git root
  local git_root = vim.fn.system("git -C " .. vim.fn.shellescape(dir) .. " rev-parse --show-toplevel 2>/dev/null")
  git_root = vim.trim(git_root)
  if git_root ~= "" and vim.fn.isdirectory(git_root) == 1 then
    return git_root
  end

  -- 2. walk up looking for project markers, stopping at $HOME
  local home = vim.fn.expand("~")
  local current = dir
  while current ~= "" and current ~= "/" do
    for _, marker in ipairs(PROJECT_MARKERS) do
      if vim.fn.filereadable(current .. "/" .. marker) == 1 then
        return current
      end
    end
    if current == home then
      break
    end
    local parent = vim.fn.fnamemodify(current, ":h")
    if parent == current then break end
    current = parent
  end

  -- 3. $HOME child: if file is somewhere under $HOME, use the immediate child of $HOME
  if dir:sub(1, #home) == home and dir ~= home then
    local rel = dir:sub(#home + 2) -- strip "~/"
    local first_segment = rel:match("^([^/]+)")
    if first_segment then
      return home .. "/" .. first_segment
    end
  end

  -- 4. fallback: file's parent directory
  return dir
end

-- Get display label for a root: "branch (short-path)" for git, "short-path" otherwise.
---@param root string
---@return string label
function M.root_label(root)
  local branch = vim.fn.system("git -C " .. vim.fn.shellescape(root) .. " rev-parse --abbrev-ref HEAD 2>/dev/null")
  branch = vim.trim(branch)
  local short = vim.fn.fnamemodify(root, ":~")
  if branch ~= "" and not branch:find("^fatal") then
    return branch .. "  " .. short
  end
  return short
end

-- Get last-modified timestamp for a root (most recent file mtime in its list).
---@param entries table[] list of {file, mtime} for this root
---@return integer mtime unix timestamp
function M.root_mtime(entries)
  local max = 0
  for _, e in ipairs(entries) do
    if e.mtime > max then max = e.mtime end
  end
  return max
end

-- Load persisted state from disk (written by the PostToolUse hook).
---@return table<string, table[]> state {root → [{file, mtime}]}
function M.load_state()
  if vim.fn.filereadable(STATE_PATH) == 0 then return {} end
  local ok, data = pcall(vim.fn.readfile, STATE_PATH)
  if not ok then return {} end
  local json = table.concat(data, "\n")
  local ok2, parsed = pcall(vim.json.decode, json)
  if not ok2 or type(parsed) ~= "table" then return {} end
  return parsed
end

-- Return the single most recently edited entry across all roots (for watch mode).
---@param state table<string, table[]>
---@return {file:string, mtime:number, line:integer|nil}|nil
function M.latest_entry(state)
  local best = nil
  for _, entries in pairs(state) do
    for _, e in ipairs(entries) do
      if best == nil or e.mtime > best.mtime then
        best = e
      end
    end
  end
  return best
end

-- Prune roots that no longer exist (in-memory, for display only — never written back).
-- For git roots: cross-reference `git worktree list`.
-- For non-git roots: directory existence check.
---@param state table<string, table[]>
function M.prune_state(state)
  for root, _ in pairs(state) do
    local keep = false

    if vim.fn.isdirectory(root) == 0 then
      -- directory gone, prune
    else
      -- check if it's a git root still tracked by git
      local wt_raw = vim.fn.system("git -C " .. vim.fn.shellescape(root) .. " worktree list --porcelain 2>/dev/null")
      if vim.v.shell_error ~= 0 or wt_raw == "" then
        -- not a git repo, keep if directory exists (already confirmed above)
        keep = true
      else
        -- parse worktree paths from `git worktree list --porcelain`
        for wt_path in wt_raw:gmatch("worktree ([^\n]+)") do
          wt_path = vim.trim(wt_path)
          if wt_path == root then
            keep = true
            break
          end
        end
      end
    end

    if not keep then
      state[root] = nil
    end
  end
end

return M
