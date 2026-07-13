# Brewfile — one-shot install of CLI tools + GUI apps for a new Mac.
#   brew bundle --file=Brewfile
# Regenerate the formula/cask baseline with:
#   brew bundle dump --file=Brewfile --force --describe
#
# Rust crates (fd, bob) and global npm packages are installed by install.sh,
# not here, so this file stays portable across Homebrew versions.

# ── CLI (formulae) ─────────────────────────────────────────────
brew "bat"                 # cat(1) with syntax highlighting
brew "fzf"                 # fuzzy finder — powers searchHistory/snippets + Ctrl-R/Ctrl-T
brew "gitleaks"            # scan repos for secrets
brew "go"
brew "llama.cpp"           # local LLM inference
brew "neovim"              # stable; nightly is managed by bob (see install.sh)
brew "node"
brew "nvm"                 # node version manager
brew "ollama", restart_service: :changed
brew "postgresql@17", restart_service: :changed, link: true
brew "pipx"                # isolated Python CLIs (termdown)
brew "pre-commit"
brew "python@3.13"
brew "redis", restart_service: :changed
brew "ripgrep"
brew "the_silver_searcher" # ag
brew "tmux"

# ── GUI apps (casks) ───────────────────────────────────────────
cask "iterm2"              # terminal
cask "font-droid-sans-mono-nerd-font"  # the font iterm2/*.plist actually selects (DroidSansMNFM)
cask "font-meslo-lg-nerd-font"         # spare Powerline/Nerd font for the agnoster zsh theme
cask "claude"              # Claude desktop
cask "docker-desktop"
cask "obsidian"
cask "google-chrome"
cask "firefox"
cask "zoom"
cask "spotify"
cask "vlc"
cask "transmission"
cask "the-unarchiver"
cask "rar"
cask "bazecor"             # Dygma split-keyboard configurator (hardware)
# cask "unity-hub"         # uncomment if you want Unity on this machine
