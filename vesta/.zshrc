# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="/Users/natewillard/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes
ZSH_THEME="agnoster"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in ~/.oh-my-zsh/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in ~/.oh-my-zsh/plugins/*
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# ssh
# export SSH_KEY_PATH="~/.ssh/rsa_id"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

alias ag='ag --pager="less -SMRi"'
alias toupper="tr '[:lower:]' '[:upper:]'"
alias tolower="tr '[:upper:]' '[:lower:]'"
alias cwd='pwd | pbcopy'
alias emptycommit='git commit -m empty --allow-empty'

# alias w3m='w3m google.com' #todo make this work if only no params
# alias google='/usr/local/bin/google.sh'
function pickaxe() { 
  git log -S "$1" $2
}
function first() {
  head -n1
}
function firstcol() {
  cut -f 1 -d' '
}
alias copy="pbcopy"
function far() {
  ag -l $1 | xargs sed -i '' "s/$1/$2/g"
}
alias dockerkillall="docker kill $(docker ps -q)"

function alarm() {
  for i in {1..10}
  do
    # OSX specific
    afplay /System/Library/Sounds/Tink.aiff -v 1
  done
}

function countdown() {
  local now=$(date +%s)
  local end=$((now + $1))
  while (( now < end )); do
    printf "%s\r" "$(date -u -j -f %s $((end - now)) +%T)"
    sleep 0.25
    now=$(date +%s)
  done
}

function alert() {
  osascript -e "tell app \"iTerm2\" to display dialog \"$1\""
}

function _pomodoro() {
  # countdown $1
  # termdown needs pip install, use countdown on new machine
  termdown $1
  alarm 
  alert "Pomodoro"
}

function pomodoro() {
  sleep_time=$(expr 25 \* 60)
  _pomodoro ${sleep_time}
}
function pombreak() {
  sleep_time=$(expr 5 \* 60)
  _pomodoro ${sleep_time}
}

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

export PATH=$PATH:$(go env GOPATH)/bin
export GOPATH=$(go env GOPATH)
export PATH=$PATH:/Users/natewillard/Library/Python/2.7/bin
export AWS_DEFAULT_REGION=us-east-2

# Use homebrew vim instead of osx vim - this will persist across osx updates
# alias vim=/usr/local/bin/vim
function note() {
  NOTEDIR=~/Projects/Notes/$(date +%F)-$1
  mkdir -p $NOTEDIR
  cd $NOTEDIR
}

function explore() {
  PROJECTDIR=~/Projects/Explorations/$(date +%F)-$1
  mkdir -p $PROJECTDIR
  cd $PROJECTDIR
}
function weather() {
  curl "wttr.in/San+Francisco?format=v2"
}
function spotcycle() {
  osascript -e 'quit app "/Applications/Spotify.app"'
  sleep 3
  open -a Spotify
  osascript -e 'tell application "spotify" to play'
}
export PATH=/Users/natewillard/.toolbox/bin:$PATH

function expose-ngrok() {
  docker run --rm --net=host -e NGROK_PORT="$1" wernight/ngrok
}

alias addSavePush="git add -A && git commit -m 'save' --no-verify && git push"
alias searchHistory="history | fzf -e"

# Vesta things
export DOTNET_ENVIRONMENT="Development"
export ASPNETCORE_ENVIRONMENT="Development"
export VAULT_ADDR="http://127.0.0.1:8200"
export VESTA_DEV_FAST_MODE="true"

# TODO: use $HOME throughout here
PATH=$PATH:/Users/natewillard/Vesta/vesta/infrastructure/scripts
export VOLTA_HOME="$HOME/.volta"
export PATH="$VOLTA_HOME/bin:$PATH"
export PATH=/opt/homebrew/bin:$PATH
export PATH=/Users/natewillard/.dotnet/tools:$PATH
export PATH=/Users/natewillard/.local/bin:$PATH
export PATH=/Users/natewillard/.dotnet/tools:$PATH

eval "$(/opt/homebrew/bin/brew shellenv)"
# Homebrew: Python
export PATH="/opt/homebrew/opt/python/libexec/bin:$PATH"
export PATH="$HOME/Downloads/nvim-nightly/nvim-macos-arm64/bin:$PATH"

# Link to fuzzy finder config
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Zsh share history across panes
setopt share_history

export EDITOR=vim

# nap config
export NAP_HOME="~/.nap"
# Colors
export NAP_THEME="nord"
export NAP_PRIMARY_COLOR="#AFBEE1"
export NAP_RED="#A46060"
export NAP_GREEN="#527251"
export NAP_FOREGROUND="7"
export NAP_BACKGROUND="0"
export NAP_BLACK="#373B41"
export NAP_GRAY="245"
export NAP_WHITE="#FFFFFF"
export NAP_DEFAULT_LANGUAGE="sh"

function snippets() {
  # TODO: allow exiting by only pressing cmd+d once
  if [[ $# -gt 0 ]]
  then nap $(nap list | fzf -q $1) | pbcopy
  else nap $(nap list | fzf) | pbcopy
  fi
}
function saveSnippet() {
  fc -ln -1 | pbcopy
  nap
}
export PATH="/usr/local/opt/libpq/bin:$PATH"
export PATH="/opt/homebrew/opt/libpq/bin:$PATH"
