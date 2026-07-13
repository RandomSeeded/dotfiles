# dotfiles

My macOS dev environment — shell, editor, terminal, and Claude Code config — as a
reproducible bundle. Rebuilt 2026-07 for a new-laptop migration.

## Quick start (new machine)

```sh
git clone git@github.com:RandomSeeded/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh
```

`install.sh` is idempotent. It installs Homebrew + everything in the `Brewfile`,
oh-my-zsh, rustup + cargo tools (`fd`, `bob`), Neovim nightly (via `bob`), global
npm packages, and fzf shell integration; imports the iTerm2 preferences; applies
`macos.sh` — then symlinks all config into place, backing up anything it would
overwrite to `~/.dotfiles-backup/<timestamp>/`.

## Layout

| Path | Symlinked to | What |
|------|--------------|------|
| `home/zshrc` | `~/.zshrc` | aliases, functions, nvim-per-tmux-window server + `vf`, `claude()` wrapper, iTerm2 CWD tracking |
| `home/zshenv` | `~/.zshenv` | loads cargo env |
| `home/tmux.conf` | `~/.tmux.conf` | `C-a` prefix, vi copy-mode, `o` → open `file:line` in nvim |
| `home/gitconfig` | `~/.gitconfig` | git identity |
| `bin/vf` | `~/.local/bin/vf` | open `file:line` in the running nvim — **iTerm2's Semantic History calls this exact path** |
| `config/git/ignore` | `~/.config/git/ignore` | global gitignore |
| `config/nvim/` | `~/.config/nvim` | LazyVim + custom `claude_follow.lua` + plugins |
| `config/ccstatusline/settings.json` | `~/.config/ccstatusline/settings.json` | Claude Code statusline layout |
| `claude/` | `~/.claude/*` | settings (allowlist pruned), `CLAUDE.md`, `/save` command, follow-along hook, custom skills (absorb/advocate/ship) |
| `ssh/config` | `~/.ssh/config` | agent + keychain defaults, GitHub host |
| `iterm2/` | (`defaults import`) | iTerm2 prefs, machine-local state stripped. `iterm2/export.sh` re-captures |
| `macos.sh` | — | the ~10 system settings that actually differ from stock macOS |
| `Brewfile` | — | CLI tools + GUI apps |

## iTerm2

`install.sh` restores prefs with `defaults import`, **not** by copying the plist into
`~/Library/Preferences`. That distinction matters: macOS caches preferences in
`cfprefsd`, so a raw copy is ignored and then silently overwritten from the cache when
iTerm2 next quits. This is the likely reason past imports appeared to "lose" settings
(the profile's `Initial Text = tmux`, for one) even though they were in the file.
iTerm2 must be quit for the import to stick.

To capture changes back into the repo after tweaking prefs in the GUI:

```sh
./iterm2/export.sh      # defaults export + strip machine-local keys
```

The committed plist is XML, not binary, so `git diff` shows which preference changed
instead of `Bin 16717 -> 31331 bytes`. `export.sh` drops ~30 keys that are per-machine
state rather than settings — window positions, Sparkle updater state, an install UUID,
and `NoSyncRecordedVariables` (~20KB of autocomplete cache). Without that strip, every
iTerm2 launch dirties the repo.

The profile selects `DroidSansMNFM` (Droid Sans Mono Nerd Font), so the Brewfile
installs `font-droid-sans-mono-nerd-font`. If that cask ever drops out, iTerm2 will
silently fall back to Monaco rather than tell you the font is missing.

## Manual follow-ups (install.sh prints these too)

- **Log out and back in** — `macos.sh`'s keyboard modifier maps (Caps Lock → Esc,
  Option/Command swap) only bind on a fresh login.
- **Re-grant privacy permissions by hand.** They live in the SIP-protected TCC database
  and cannot be scripted: Accessibility / Screen Recording / Full Disk Access /
  Automation for iTerm, VS Code, Claude, Docker, Bazecor, Zoom.
- Matt Pocock skills: ask Claude to run `/setup-matt-pocock-skills` (14 skills, not vendored here).
- Re-auth GitHub Copilot and Claude Code.
- New SSH key → add to GitHub.
- Re-pull Ollama models.
- Export/import the Bazecor keyboard layout if bringing the Dygma. Note that no export
  exists yet — the Defy layout currently lives only in the keyboard's onboard flash,
  and `~/Dygma/Backups/` is empty with auto-backup disabled.

## macOS settings

`macos.sh` writes only the settings this machine actually deviates from stock on:
natural scrolling off, three keyboard modifier maps, two disabled input-source hotkeys
(freeing Ctrl+Space for editor autocomplete), Dock autohide, Finder list view,
no-miniaturize-on-double-click, always-show-volume.

Everything else an audit checked — trackpad gestures, key repeat, text substitution,
hot corners, dark mode, screenshot options, the Dock's app list — is at Apple's
defaults on this machine and is deliberately **not** scripted. A `macos.sh` that writes
200 keys, 190 of which are already the default, hides the 10 that matter.

Two gotchas encoded in the script: modifier maps live in the **per-host** domain
(`defaults -currentHost`, invisible to a plain `defaults read -g`) and are keyed by USB
vendor/product ID, so the external-keyboard entries are inert on a Mac without that
hardware attached.

## What was intentionally dropped in the 2026-07 refresh

Old-job / dead config removed from the previous `.zshrc`/`.zshenv`: the Vesta env
block (`VAULT_ADDR`, `ASPNETCORE_ENVIRONMENT`, `VESTA_DEV_FAST_MODE`, Vesta script
paths), the `~/.toolbox` path, `AWS_DEFAULT_REGION`, volta, the hand-installed
.NET SDK paths (`DOTNET_ROOT`, dotnet tools), the `~/Downloads/nvim-nightly` path
(now via `bob`), the OpenClaw completion, and a defunct Python 2.7 path.

Not vendored (regenerate on the new machine): the 14 Matt Pocock skills
(`~/.agents/skills`), Ollama models, and all secrets/auth (SSH key, Copilot
`auth.db`, Claude credentials).

## Notes

- `claude/settings.json` has had its permission allowlist pruned to generic, reusable
  rules (project-specific one-offs from the old machine were removed).
- Full pre-migration audit (carry / drop / regenerate decisions per item):
  see the Port Manifest artifact.
