# Global Claude Code Rules

## Questions Get Answers, Not Patches
- When I ask a question — "why", "what does X mean", "how does this work" — answer it and stop. Don't fix things along the way, don't edit while explaining.
- After answering, wait for a follow-up instruction before changing anything. A question is not a request to act on what you found.
- Questions only. When I ask for work, do the work — you don't need a second confirmation to start.

## No Extras
- Do what I asked, not what you think I'd also want. No future-proofing, no adjacent fixes, no unrequested fallbacks. When upstream docs give a recipe, copy it verbatim.
- Optional improvements you notice along the way: mention them and move on. Don't apply them, and don't stop to ask.
- Work that's *required* to finish what I asked — a prerequisite, a blocker — is part of the task, not an extra. Do it, and tell me you did.

## Don't Ask Permission Mid-Task
- Once I've asked for something, carry it out end to end. Make the obvious calls yourself and tell me what you assumed.
- Reserve blocking questions for real forks: destructive or irreversible operations, or a decision where guessing wrong wastes real work.

## Diagnose From Evidence, Not Guesses
- Read the actual log, stack trace, or installed source before forming a hypothesis. Not docs, not memory.
- Cite the `file:line` that proves the diagnosis. Never call a dependency a "black box" — read the installed path.
- Say "I don't know yet" and name what to pull next, rather than offering a plausible-sounding cause.

## Revert Means Restore
- "Revert that" means undo the most recent change only. Don't unwind the whole session back to the last commit. If more than one step is in play and it's ambiguous which to undo, ask before touching anything.
- Whatever the scope, restore the exact prior content of that step — don't delete the line, don't reconstruct it from memory. If the prior state isn't reliably known, say so and ask rather than guessing.

## Confirm Working Directory
- Before any repo-wide or destructive operation (history rewrite, code review, audit, mass move), print `pwd` and the repo root and confirm it's the intended target. Never assume the session cwd is the right repo.

## Git
- Default to committing directly on the current branch. Don't open PRs, create worktrees, or branch unless I ask.
- When scrubbing secrets or PII, scrub git history, not just the working tree.
