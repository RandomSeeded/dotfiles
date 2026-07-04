Run `git status` and `git diff --stat HEAD 2>/dev/null || git diff --stat` to see what has changed. If there are uncommitted changes:

1. Consider whether an ADR is warranted for any decision made during this work. If so, create it in `docs/adr/` before committing.
2. Draft a commit message that records what this chunk of work contains.
3. Commit immediately. Only pause to ask the user if you cannot determine what should be included in the commit — for example, unrelated untracked files where it's unclear which belong. If you do pause, say what's ambiguous and wait up to 1 minute before proceeding with your best judgment.

If there is nothing to commit, say so briefly.

If the session is running in a worktree (cwd is under `.claude/worktrees/`), merge the worktree branch back after committing, then exit the worktree:

**Merge:**
- Determine the worktree branch name with `git branch --show-current`.
- **Check the target checkout for uncommitted changes first:** run `git -C <repo-root> status --porcelain`. If it is non-empty, the merge will abort ("Please commit your changes or stash them before you merge"). Stash them before merging so they aren't lost: `git -C <repo-root> stash push -m "save-cmd: pre-merge stash"` (these are unrelated in-progress edits in the main checkout, not part of this worktree's work — preserve them, don't discard). Remember that you stashed, so you pop after the worktree is removed (see below).
- Run `git -C <repo-root> merge <worktree-branch>` to merge into main (use `git worktree list` to find the repo root).
- If the work belongs on a named feature branch rather than main, check that out first, then merge.
- Report the result (fast-forward, merge commit, or conflicts to resolve).

**Exit the worktree** — only after a clean merge, and only behind BOTH safety gates:

- **Gate 1 — work is captured:** verify the worktree branch's HEAD is contained in the branch you merged into, with `git -C <repo-root> merge-base --is-ancestor <worktree-HEAD> <target>`. The merge must have completed with no conflicts.
- **Gate 2 — tree is clean:** verify `git -C <worktree> status --porcelain` is empty (no untracked or unstaged files that would be lost).

If BOTH gates pass, removal is **mandatory** — having more work queued is *not* a reason to keep the worktree (the next unit of work gets its own fresh worktree), and neither is a process running from it. The only sanctioned reason to keep a gates-passed worktree is none; keep only on gate failure (below). Remove it:
- **First, stop anything running from the worktree.** Dev servers, file watchers, or a tmux session started inside the worktree directory will break when it is removed. Stop them before removal; if the user is actively using one (e.g. a live preview), restart it from the repo root *after* the worktree is gone and tell them where it moved.
- Try the `ExitWorktree` tool with `action: "remove"` and `discard_changes: true` (provably safe — the only commits it warns about are the ones Gate 1 confirmed are on the target).
- If `ExitWorktree` reports no active worktree session (no-op), fall back to: `git -C <repo-root> worktree remove <path> --force` then `git -C <repo-root> branch -D <worktree-branch>`.
- Confirm the session's cwd is back at the repo root.
- **If you stashed pre-merge changes earlier, pop them now** (after the worktree is removed and cwd is back at the repo root): `git stash pop`. Then check `git status` — if the pop produced conflict markers, report them loudly and leave them for the user to resolve; do not commit them. Otherwise confirm the restored changes are back in the working tree, uncommitted.

If EITHER gate fails (merge conflicted/aborted, commits not contained, or leftover uncommitted files), do NOT remove. Keep the worktree (`ExitWorktree` with `action: "keep"`, or simply leave it) and report loudly that it was preserved, why, and which files/commits are at risk.
