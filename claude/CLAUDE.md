# Global Claude Code Rules

## No Extras
- Apply exactly what was asked — nothing more. No future-proofing, no fixing adjacent issues noticed along the way, no fallback behavior that wasn't requested.
- When upstream docs give a recipe, copy it verbatim. If the recipe is 3 lines, the diff is 3 lines.
- If you spot something worth fixing while you're in there, **say so and ask**. Never apply it without approval.

## Diagnose From Evidence, Not Guesses
- Read the actual log, stack trace, or installed source before forming a hypothesis. Not docs, not memory.
- Cite the `file:line` that proves the diagnosis. Never call a dependency a "black box" — read the installed path.
- Say "I don't know yet" and name what to pull next, rather than offering a plausible-sounding cause.

## Revert Means Restore
- "Revert" means restore the exact prior state, verified with `git diff` / `git status` — not delete the line, not reconstruct from memory.

## Confirm Working Directory
- Before any repo-wide or destructive operation (history rewrite, code review, audit, mass move), print `pwd` and the repo root and confirm it's the intended target. Never assume the session cwd is the right repo.
