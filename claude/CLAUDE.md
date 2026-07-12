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
- "Revert that" means undo the most recent change only. Don't unwind the whole session back to the last commit. If more than one step is in play and it's ambiguous which to undo, ask before touching anything.
- Whatever the scope, restore the exact prior content of that step — don't delete the line, don't reconstruct it from memory. If the prior state isn't reliably known, say so and ask rather than guessing.

## Confirm Working Directory
- Before any repo-wide or destructive operation (history rewrite, code review, audit, mass move), print `pwd` and the repo root and confirm it's the intended target. Never assume the session cwd is the right repo.
