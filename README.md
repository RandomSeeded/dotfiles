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
npm packages, and fzf shell integration — then symlinks all config into place,
backing up anything it would overwrite to `~/.dotfiles-backup/<timestamp>/`.

## Layout

| Path | Symlinked to | What |
|------|--------------|------|
| `home/zshrc` | `~/.zshrc` | aliases, functions, nvim-per-tmux-window server + `vf`, `claude()` wrapper, iTerm2 CWD tracking |
| `home/zshenv` | `~/.zshenv` | loads cargo env |
| `home/tmux.conf` | `~/.tmux.conf` | `C-a` prefix, vi copy-mode, `o` → open `file:line` in nvim |
| `home/gitconfig` | `~/.gitconfig` | git identity |
| `config/git/ignore` | `~/.config/git/ignore` | global gitignore |
| `config/nvim/` | `~/.config/nvim` | LazyVim + custom `claude_follow.lua` + plugins |
| `config/ccstatusline/settings.json` | `~/.config/ccstatusline/settings.json` | Claude Code statusline layout |
| `claude/` | `~/.claude/*` | settings, `CLAUDE.md`, `/save` command, follow-along hook, custom skills (absorb/advocate/ship) |
| `Brewfile` | — | CLI tools + GUI apps |

## Manual follow-ups (install.sh prints these too)

- Powerline/Nerd font in iTerm2 (for the agnoster theme) + import iTerm2 prefs.
- Matt Pocock skills: ask Claude to run `/setup-matt-pocock-skills` (14 skills, not vendored here).
- Re-auth GitHub Copilot and Claude Code.
- New SSH key → add to GitHub.
- Re-pull Ollama models.
- Export/import the Bazecor keyboard layout if bringing the Dygma.

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

- `claude/settings.json` is copied verbatim, including a large permission allowlist
  that accumulated project-specific one-offs over time — prune at will.
- Full pre-migration audit (carry / drop / regenerate decisions per item):
  see the Port Manifest artifact.
