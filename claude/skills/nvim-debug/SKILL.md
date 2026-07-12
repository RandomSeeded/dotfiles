---
name: nvim-debug
description: Diagnose a Neovim/LSP issue from real evidence, then prove the diagnosis by experiment before proposing a change.
---

Diagnose this Neovim issue: $ARGUMENTS

Do not skip or reorder these steps.

## 1. Pull the real evidence first

Before forming any hypothesis, get the actual artifact:

- `:messages` — the error as Neovim reported it
- `~/.local/state/nvim/lsp.log` — LSP handshake, server crashes, init options
- `:checkhealth <plugin>` — for plugin-level breakage
- The exact Lua stack trace, verbatim

If you can't reach one of these yourself, ask the user to paste it. Do not proceed on a symptom description alone.

## 2. Read the installed source, not the docs

Read the actual code that's running, under `~/.local/share/nvim/lazy/<plugin>/`. Not the README, not GitHub, not memory. If a dependency's behavior is in question, open its installed path — never call it a black box.

## 3. Name the root cause with proof

State the cause and cite the `file:line` that establishes it. If the evidence doesn't support a conclusion, say "I don't know yet" and name the next thing to pull. A plausible story is not a diagnosis.

## 4. Prove it by experiment

A diagnosis isn't confirmed until changing the suspected cause changes the symptom. To prove it:

- **Checkpoint first.** Record the exact prior state of every file you're about to touch, so it can be restored byte-for-byte.
- **Write the prediction down before running it.** "If the pane_pid collision is the cause, splitting the tmux panes stops the duplicate-id error." Stated up front, so it can actually fail.
- **Test both directions.** The symptom disappears with the change, and returns when you pull it back out. One direction is correlation.
- **Restore the checkpoint.** The experiment is an instrument, not a commit.

## 5. Propose, don't land

Show the diff and stop. Landing it is the user's call.

If the plugin's own docs contain a recipe for the fix, copy it verbatim — no `opts` function wrappers, no future-proofing, no adjacent fixes.
