#!/usr/bin/env python3
"""Claude Code PostToolUse hook: record files Claude edits, grouped by project root.

Reads the hook JSON payload on stdin (tool_name, tool_input, ...), extracts the
edited file path, computes its project root, and updates the shared state file
that the nvim claude-follow picker reads:

    ~/.local/share/nvim/claude-follow.json
    { "<root>": [ {"file": "<abs path>", "mtime": <unix int>}, ... ], ... }

Root resolution mirrors claude_follow.lua's find_root:
    git root -> project marker (up to $HOME) -> $HOME child -> file's parent dir.

Concurrency-safe via an exclusive flock on the state file (multiple interactive
and background Claude sessions may fire this simultaneously).
"""
import fcntl
import json
import os
import subprocess
import sys
import time

STATE_PATH = os.path.expanduser("~/.local/share/nvim/claude-follow.json")
HOME = os.path.expanduser("~")
MARKERS = (
    "package.json", "Cargo.toml", "pyproject.toml", "go.mod", ".envrc",
    "Makefile", "CMakeLists.txt", "mix.exs", ".project",
)
# tool_input keys that carry an edited file path, by tool family.
PATH_KEYS = ("file_path", "notebook_path")


def find_edit_range(file_path: str, new_text: str) -> "tuple[int, int] | None":
    """Return 1-indexed (start, end) line range where new_text appears in file_path."""
    if not new_text:
        return None
    first_line = next((l for l in new_text.splitlines() if l.strip()), None)
    if not first_line:
        return None
    n_lines = max(1, len(new_text.splitlines()))
    try:
        with open(file_path, errors="replace") as f:
            for i, line in enumerate(f, 1):
                if first_line in line:
                    return (i, i + n_lines - 1)
    except Exception:
        pass
    return None


def find_root(file_path: str) -> str:
    d = os.path.dirname(file_path)

    # 1. git root
    try:
        out = subprocess.run(
            ["git", "-C", d, "rev-parse", "--show-toplevel"],
            capture_output=True, text=True, timeout=5,
        )
        root = out.stdout.strip()
        if root and os.path.isdir(root):
            return root
    except Exception:
        pass

    # 2. walk up for a project marker, stopping at $HOME
    cur = d
    while cur and cur != "/":
        for m in MARKERS:
            if os.path.isfile(os.path.join(cur, m)):
                return cur
        if cur == HOME:
            break
        parent = os.path.dirname(cur)
        if parent == cur:
            break
        cur = parent

    # 3. $HOME child
    if d.startswith(HOME) and d != HOME:
        rel = d[len(HOME) + 1:]
        first = rel.split("/", 1)[0] if rel else ""
        if first:
            return os.path.join(HOME, first)

    # 4. fallback: parent dir
    return d


def record(state: dict, file_path: str, line: "int | None" = None, line_end: "int | None" = None) -> None:
    root = find_root(file_path)
    entries = state.setdefault(root, [])
    # Sub-second resolution so edits within the same second still order by recency.
    # lua's os.date()/numeric sort handle float mtimes fine.
    now = time.time()
    for e in entries:
        if e.get("file") == file_path:
            e["mtime"] = now
            if line is not None:
                e["line"] = line
            if line_end is not None:
                e["line_end"] = line_end
            elif "line_end" in e:
                del e["line_end"]
            break
    else:
        entry: dict = {"file": file_path, "mtime": now}
        if line is not None:
            entry["line"] = line
        if line_end is not None:
            entry["line_end"] = line_end
        entries.append(entry)
    entries.sort(key=lambda e: e.get("mtime", 0), reverse=True)


def main() -> int:
    try:
        payload = json.load(sys.stdin)
    except Exception:
        return 0  # malformed payload: never block Claude

    tool_name = payload.get("tool_name", "")
    tool_input = payload.get("tool_input") or {}
    raw = next((tool_input[k] for k in PATH_KEYS if tool_input.get(k)), None)
    if not raw:
        return 0
    file_path = os.path.abspath(os.path.expanduser(raw))

    # Determine the line range of the edit for watch-mode jumping and highlighting.
    line_range: "tuple[int, int] | None" = None
    if tool_name == "Edit":
        line_range = find_edit_range(file_path, tool_input.get("new_string") or "")
    elif tool_name == "MultiEdit":
        edits = tool_input.get("edits") or []
        if edits:
            line_range = find_edit_range(file_path, edits[0].get("new_string") or "")
    elif tool_name == "Write":
        try:
            with open(file_path, errors="replace") as f:
                n = sum(1 for _ in f)
            line_range = (1, max(1, n))
        except Exception:
            line_range = (1, 1)
    line = line_range[0] if line_range else None
    line_end = line_range[1] if line_range else None

    os.makedirs(os.path.dirname(STATE_PATH), exist_ok=True)
    # Open r+ if it exists, else create. Hold an exclusive lock for read-modify-write.
    fd = os.open(STATE_PATH, os.O_RDWR | os.O_CREAT, 0o644)
    with os.fdopen(fd, "r+") as f:
        fcntl.flock(f, fcntl.LOCK_EX)
        try:
            f.seek(0)
            text = f.read()
            try:
                state = json.loads(text) if text.strip() else {}
                if not isinstance(state, dict):
                    state = {}
            except Exception:
                state = {}
            record(state, file_path, line, line_end)
            f.seek(0)
            f.truncate()
            json.dump(state, f)
        finally:
            fcntl.flock(f, fcntl.LOCK_UN)
    return 0


if __name__ == "__main__":
    sys.exit(main())
