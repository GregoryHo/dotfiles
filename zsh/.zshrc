# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# OPENSPEC:START
# OpenSpec shell completions configuration — fpath only; Oh My Zsh runs compinit later.
fpath=("/Users/gregho/.oh-my-zsh/custom/completions" $fpath)
# OPENSPEC:END

# Locale safety for Nerd Font/powerline symbols.
export LANG="${LANG:-en_US.UTF-8}"
export LC_CTYPE="${LC_CTYPE:-en_US.UTF-8}"

# Shared environment source of truth (required for non-login zsh shells).
[ -f "$HOME/GitHub/dotfiles/shell/.env.shared.sh" ] && . "$HOME/GitHub/dotfiles/shell/.env.shared.sh"

# tmu support 256 color
export TERM="xterm-256color"

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH
export ZSH=/Users/gregho/.oh-my-zsh

# Set name of the theme to load. Optionally, if you set this to "random"
# it'll load a random theme each time that oh-my-zsh is loaded.
# See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes
ZSH_THEME="powerlevel10k/powerlevel10k"

# disable share histoary
unsetopt share_history

# History in cache directory:
HISTSIZE=15000
SAVEHIST=15000
# HISTFILE=~/.cache/zsh/history

# Basic auto/tab complete:
zstyle ':completion:*' menu select
zmodload zsh/complist
_comp_options+=(globdots)		# Include hidden files.

# Set list of themes to load
# Setting this variable when ZSH_THEME=random
# cause zsh load theme from this variable instead of
# looking in ~/.oh-my-zsh/themes/
# An empty array have no effect
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion. Case
# sensitive completion must be off. _ and - will be interchangeable.
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
# The optional three formats: "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
  zsh-syntax-highlighting
  docker
  git
  # nvm, node, npm - using lazy loading
  # minikube - lazy-loaded in .zshrc.local
  kubectl
  tmux
  react-native
)
# zsh-autosuggestions
# zsh-completions

source $ZSH/oh-my-zsh.sh

# OMZ termsupport registers omz_termsupport_precmd twice — dedupe.
precmd_functions=("${(@u)precmd_functions}")
preexec_functions=("${(@u)preexec_functions}")

# User configuration

# NVM — eager PATH, lazy nvm command
# Replicate what `nvm use --silent <default>` does without sourcing the full
# nvm.sh (3500+ lines of shell functions). This makes ALL globally-installed
# npm tools (mgrep, etc.) available immediately.
#
# What we replicate from `nvm use` (nvm.sh lines 2935-2955):
#   1. PATH     — add default node version's bin
#   2. NVM_BIN  — export for node-gyp / third-party tools
#   3. MANPATH  — add default node version's share/man
#   4. hash -r  — flush shell command cache
export NVM_DIR="$HOME/.nvm"

# Eagerly resolve default node version and set up environment
if [ -s "$NVM_DIR/alias/default" ]; then
  _nvm_ver=$(cat "$NVM_DIR/alias/default")
  _nvm_ver="${_nvm_ver#v}"
  # Exact match first (e.g. v22.12.0), glob fallback for partial versions (e.g. 22)
  _nvm_node_dir="$NVM_DIR/versions/node/v${_nvm_ver}"
  [ -d "$_nvm_node_dir" ] || _nvm_node_dir=$(ls -d "$NVM_DIR/versions/node/v${_nvm_ver}"* 2>/dev/null | sort -V | tail -1)
  if [ -d "$_nvm_node_dir" ]; then
    export PATH="$_nvm_node_dir/bin:$PATH"
    export NVM_BIN="$_nvm_node_dir/bin"
    export MANPATH="$_nvm_node_dir/share/man${MANPATH:+:$MANPATH}"
    hash -r 2>/dev/null
  fi
  unset _nvm_ver _nvm_node_dir
fi

# Lazy load nvm command only (the expensive part: ~80 function definitions)
# --no-use skips nvm_auto("use") since we already set up the environment above.
nvm() {
  unset -f nvm
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" --no-use
  nvm "$@"
}

# zsh-highlight
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets pattern cursor)
ZSH_HIGHLIGHT_STYLES[path]=none
ZSH_HIGHLIGHT_STYLES[path_prefix]=none
ZSH_HIGHLIGHT_STYLES[cursor]='bold'
ZSH_HIGHLIGHT_STYLES[alias]='fg=blue,bold'
ZSH_HIGHLIGHT_STYLES[suffix-alias]='fg=blue,bold'
ZSH_HIGHLIGHT_STYLES[builtin]='fg=blue,bold'
ZSH_HIGHLIGHT_STYLES[function]='fg=blue,bold'
ZSH_HIGHLIGHT_STYLES[command]='fg=blue,bold'
ZSH_HIGHLIGHT_STYLES[precommand]='fg=blue,bold'
ZSH_HIGHLIGHT_STYLES[hashed-command]='fg=blue,bold'

# zsh-tmux
ZSH_TMUX_AUTOSTART=true
ZSH_TMUX_ITERM2=true

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

# fzf settings

# Load the source
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Set the color scheme
_gen_fzf_default_opts() {
  local base03="234"
  local base02="235"
  local base01="240"
  local base00="241"
  local base0="244"
  local base1="245"
  local base2="254"
  local base3="230"
  local yellow="136"
  local orange="166"
  local red="160"
  local magenta="125"
  local violet="61"
  local blue="33"
  local cyan="37"
  local green="64"

  # Comment and uncomment below for the light theme.
  # Solarized Dark color scheme for fzf
  export FZF_DEFAULT_OPTS="
    --color fg:-1,bg:-1,hl:$blue,fg+:$base2,bg+:$base02,hl+:$blue
    --color info:$yellow,prompt:$yellow,pointer:$base3,marker:$base3,spinner:$yellow
    --height 40% --exact --border --cycle --reverse --inline-info
    --bind 'ctrl-alt-u:preview-up'
    --bind 'ctrl-alt-d:preview-down'
    --bind 'f1:execute(less -f {}),ctrl-y:execute-silent(echo {} | pbcopy)+abort'
  "
  ## Solarized Light color scheme for fzf
  #export FZF_DEFAULT_OPTS="
  #  --color fg:-1,bg:-1,hl:$blue,fg+:$base02,bg+:$base2,hl+:$blue
  #  --color info:$yellow,prompt:$yellow,pointer:$base03,marker:$base03,spinner:$yellow
  # --height 35% --border --inline-info
  #"
}
_gen_fzf_default_opts
# Use ~~ as the trigger sequence instead of the default **
export FZF_COMPLETION_TRIGGER='~~'
# Options to fzf command
export FZF_COMPLETION_OPTS='+c -x'
# Use fd (https://github.com/sharkdp/fd) instead of the default find
# command for listing path candidates.
# - The first argument to the function ($1) is the base path to start traversal
# - See the source code (completion.{bash,zsh}) for the details.
_fzf_compgen_path() {
  fd --hidden --follow --exclude ".git" . "$1"
}
# Use fd to generate the list for directory completion
_fzf_compgen_dir() {
  fd --type d --hidden --follow --exclude ".git" . "$1"
}
# Setting fd as the default source for fzf
export FZF_DEFAULT_COMMAND='fd --type f'
# To apply the command to CTRL-T as well
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
# Uses tree command to show the entries of the directory.
export FZF_ALT_C_OPTS="--preview 'tree -C {} | head -200'"

# Load local source
[ -f ~/.zshrc.local ] && source ~/.zshrc.local

# Ghostty-specific layer (terminal-specific, machine-agnostic; gated by $TERM internally)
[ -f "$HOME/GitHub/dotfiles/zsh/ghostty.zsh" ] && . "$HOME/GitHub/dotfiles/zsh/ghostty.zsh"

# Keep startup lean. Run fastfetch manually when needed.
alias ff='fastfetch'
eval "$(rbenv init - zsh)"
# Docker Desktop CLI completions.
fpath=(/Users/gregho/.docker/completions $fpath)

# GVM disabled - causing cd slowdown
# [[ -s "/Users/gregho/.gvm/scripts/gvm" ]] && source "/Users/gregho/.gvm/scripts/gvm"

# bun completions
[ -s "/Users/gregho/.bun/_bun" ] && source "/Users/gregho/.bun/_bun"

# Powerlevel10k config (segments + styles). Tracked in dotfiles repo.
# Wifi custom segment lives in zsh/wifi-segment.zsh — sourced only if enabled.
[ -f "$HOME/GitHub/dotfiles/zsh/.p10k.zsh" ] && source "$HOME/GitHub/dotfiles/zsh/.p10k.zsh"
# [ -f "$HOME/GitHub/dotfiles/zsh/wifi-segment.zsh" ] && source "$HOME/GitHub/dotfiles/zsh/wifi-segment.zsh"
