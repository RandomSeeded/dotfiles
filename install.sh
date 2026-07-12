#!/usr/bin/env bash
# Bootstrap a fresh macOS machine from this dotfiles repo.
# Idempotent: safe to re-run. Anything it would overwrite is backed up first.
#
#   ./install.sh
#
# Testing:
#   LINKS_ONLY=1 HOME=/tmp/dt ./install.sh   # only create symlinks, skip all installs
#
set -uo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"

info() { printf '\033[1;34m==>\033[0m %s\n' "$1"; }

link() {
  local src="$1" dst="$2"
  [ -e "$src" ] || { echo "  skip (missing source): $src"; return; }
  mkdir -p "$(dirname "$dst")"
  if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then
    echo "  ok: $dst"; return
  fi
  if [ -e "$dst" ] || [ -L "$dst" ]; then
    mkdir -p "$BACKUP/$(dirname "${dst#"$HOME"/}")"
    mv "$dst" "$BACKUP/${dst#"$HOME"/}"
    echo "  backed up existing $dst"
  fi
  ln -s "$src" "$dst"
  echo "  linked $dst -> $src"
}

# All install steps below are skipped when LINKS_ONLY=1 (for testing the symlinks).
if [ "${LINKS_ONLY:-0}" != "1" ]; then

# ── 1. Homebrew ────────────────────────────────────────────────
if ! command -v brew >/dev/null 2>&1; then
  info "Installing Homebrew"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
eval "$(/opt/homebrew/bin/brew shellenv)"

info "Installing packages from Brewfile"
brew bundle --file="$DOTFILES/Brewfile" || echo "  (some Brewfile entries failed — continuing)"

# ── 2. oh-my-zsh (theme: agnoster — needs a Powerline/Nerd font in iTerm2) ──
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  info "Installing oh-my-zsh"
  RUNZSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

# ── 3. Rust + cargo tools (fd, bob) ────────────────────────────
if ! command -v rustup >/dev/null 2>&1; then
  info "Installing rustup"
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
fi
[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"
info "Installing cargo tools (fd, bob)"
cargo install fd-find bob-nvim || echo "  (cargo install skipped/failed — continuing)"

# ── 3b. Extra CLI tools (nap snippets, termdown pomodoro, nvim python provider) ──
info "Installing nap, termdown, pynvim"
command -v go   >/dev/null 2>&1 && go install github.com/maaslalani/nap@latest || true
command -v pipx >/dev/null 2>&1 && pipx install termdown || true
python3 -m pip install --user pynvim 2>/dev/null \
  || python3 -m pip install --user --break-system-packages pynvim 2>/dev/null || true

# ── 4. Neovim nightly via bob ──────────────────────────────────
if command -v bob >/dev/null 2>&1; then
  info "Setting Neovim nightly via bob"
  bob install nightly || true
  bob use nightly || true
fi

# ── 5. Global npm packages ─────────────────────────────────────
if command -v npm >/dev/null 2>&1; then
  info "Installing global npm packages"
  npm install -g @github/copilot-language-server ccstatusline neovim || true
fi

# ── 6. fzf key bindings + completion ───────────────────────────
if [ -x "$(brew --prefix)/opt/fzf/install" ]; then
  info "Installing fzf shell integration"
  "$(brew --prefix)/opt/fzf/install" --key-bindings --completion --no-update-rc || true
fi

fi  # end install steps (skipped when LINKS_ONLY=1)

# ── 7. Symlinks ────────────────────────────────────────────────
info "Linking dotfiles"
link "$DOTFILES/home/zshrc"        "$HOME/.zshrc"
link "$DOTFILES/home/zshenv"       "$HOME/.zshenv"
link "$DOTFILES/home/tmux.conf"    "$HOME/.tmux.conf"
link "$DOTFILES/home/gitconfig"    "$HOME/.gitconfig"
link "$DOTFILES/config/git/ignore" "$HOME/.config/git/ignore"
link "$DOTFILES/config/nvim"       "$HOME/.config/nvim"
link "$DOTFILES/config/ccstatusline/settings.json" "$HOME/.config/ccstatusline/settings.json"

mkdir -p "$HOME/.ssh" && chmod 700 "$HOME/.ssh"
link "$DOTFILES/ssh/config" "$HOME/.ssh/config"

info "Linking Claude Code config"
link "$DOTFILES/claude/settings.json"                      "$HOME/.claude/settings.json"
link "$DOTFILES/claude/CLAUDE.md"                          "$HOME/.claude/CLAUDE.md"
link "$DOTFILES/claude/commands/save.md"                   "$HOME/.claude/commands/save.md"
link "$DOTFILES/claude/hooks/claude_follow_record.py"      "$HOME/.claude/hooks/claude_follow_record.py"
link "$DOTFILES/claude/hooks/claude_follow_record_test.py" "$HOME/.claude/hooks/claude_follow_record_test.py"
for s in absorb advocate nvim-debug ship; do
  link "$DOTFILES/claude/skills/$s" "$HOME/.claude/skills/$s"
done

cat <<'EOF'

Done. Manual follow-ups the script can't do:
  • In iTerm2, select "MesloLGS Nerd Font" (installed via Brewfile) for the agnoster theme,
    and import prefs: iTerm2 > Settings > General > Preferences > load from ~/dotfiles/iterm2/.
  • Install the Matt Pocock skills:  ask Claude to run /setup-matt-pocock-skills
  • Re-authenticate GitHub Copilot and Claude Code (claude, then /login).
  • Generate a new SSH key and add it to GitHub:
        ssh-keygen -t ed25519 -C "nate.a.willard@gmail.com"
  • Re-pull any Ollama models you want:  ollama pull <model>
  • Export/import your Bazecor keyboard layout if bringing the Dygma.

Open a new terminal (or run `exec zsh`) to load the new shell config.
EOF
