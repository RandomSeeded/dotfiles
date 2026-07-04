---
name: ship
description: Milestone checkpoint that runs code-review, simplify, and save in sequence. Use when user says "ship", "done", "checkpoint", or "commit this".
---

# Ship

Run these four steps in order. Do not skip any step even if a previous one finds nothing to change.

1. Invoke `code-review` — then address its findings before continuing. Fix every correctness
   bug, and for each remaining finding of import (security, data-integrity, UX, cleanup) either
   apply the fix or make a deliberate, recorded decision to defer it. Do not proceed while
   important findings sit unaddressed.
2. Invoke `simplify` — apply any cleanups it produces.
3. Invoke `save` — commit the result. If the session is in a worktree, `save` also merges it to
   the target branch and removes the worktree. Before declaring the ship done, confirm
   `git worktree list` shows no leftover worktree for this work — a worktree may remain *only* if
   a `save` safety-gate failed, in which case say so loudly and explain why. "More work coming"
   or "a server is running from it" are not reasons to leave it; if either applies, follow `save`'s
   guidance (fresh worktree for the next task; stop/restart the process from the repo root).
4. Run `git push` — push the commit to the remote.
