---
name: absorb
description: Load the handoff document left by the previous session so you can continue the work.
---

Handoff documents are stored in `~/.claude/handoffs/` as `<YYYYMMDD-HHMMSS>-<label>.md` files.

**Determine which file to load based on how the skill was invoked:**

- **No argument** — load the most recent file (highest timestamp). If none exist, say so and ask the user what they'd like to work on.
- **`list`** — present a selector (see below) and load whichever the user picks.
- **Any other argument** — treat it as a label fragment and find the best match. If exactly one match, load it. If multiple matches or no match, present the selector and load whichever the user picks.

**Selector**: use the `AskUserQuestion` tool with a single-select question titled "Which handoff would you like to load?". List files most-recent-first; each option's label is `<timestamp> — <label>` and its description is the full filename.

Once you have a file, read it and internalize everything: decisions made, open questions, suggested skills, and files to read. Then read any files listed in the "Files to read first" section.

Once absorbed, briefly confirm to the user what you understand the current state to be and what the next step is. Then wait for their instruction — do not start implementing anything unprompted.
