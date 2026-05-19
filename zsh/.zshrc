# OpenSpec shell completions configuration — fpath only.
# OPENSPEC:START
fpath=("/Users/gregho/.oh-my-zsh/custom/completions" $fpath)
# OPENSPEC:END

# Locale safety for Nerd Font / powerline symbols.
export LANG="${LANG:-en_US.UTF-8}"
export LC_CTYPE="${LC_CTYPE:-en_US.UTF-8}"

# Shared environment source of truth (required for non-login zsh shells).
[ -f "$HOME/GitHub/dotfiles/shell/.env.shared.sh" ] && . "$HOME/GitHub/dotfiles/shell/.env.shared.sh"

# tmux 256-color support.
export TERM="xterm-256color"

# History.
unsetopt share_history
HISTSIZE=15000
SAVEHIST=15000

# Completion UX.
zstyle ':completion:*' menu select
zmodload zsh/complist
_comp_options+=(globdots)

# compinit MUST run before antidote loads fzf-tab.
autoload -Uz compinit
compinit -C

# Antidote plugin manager.
source /opt/homebrew/share/antidote/antidote.zsh
antidote load

# fzf-tab tuning (after antidote load).
zstyle ':fzf-tab:complete:cd:*' fzf-preview \
  'eza -1 --color=always $realpath 2>/dev/null || ls -1 --color=always $realpath'
zstyle ':fzf-tab:complete:*:*' fzf-flags --height=40% --reverse --border
zstyle ':completion:*:descriptions' format '[%d]'
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':fzf-tab:*' switch-group ',' '.'

# fast-syntax-highlighting overrides (replaces ZSH_HIGHLIGHT_STYLES).
_dot_fsh_overrides() {
  [[ -n ${FAST_THEME_NAME-} ]] || return 0
  local k
  for k in command alias builtin function precommand suffix-alias hashed-command; do
    FAST_HIGHLIGHT_STYLES[${FAST_THEME_NAME}${k}]='fg=blue,bold'
  done
}
_dot_fsh_overrides

# Starship prompt.
eval "$(starship init zsh)"

# NVM — eager PATH, lazy nvm command.
# Replicate what `nvm use --silent <default>` does without sourcing nvm.sh
# (3500+ lines). This makes all globally-installed npm tools available
# immediately. Lazy-load nvm itself on first invocation.
export NVM_DIR="$HOME/.nvm"

if [ -s "$NVM_DIR/alias/default" ]; then
  _nvm_ver=$(cat "$NVM_DIR/alias/default")
  _nvm_ver="${_nvm_ver#v}"
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

nvm() {
  unset -f nvm
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" --no-use
  nvm "$@"
}

# tmux auto-start (replaces OMZ tmux plugin — only the autostart part).
if [[ -z "$TMUX" && "${ZSH_TMUX_AUTOSTART:-true}" == "true" && "${ZSH_TMUX_AUTOSTARTED:-}" != "true" ]]; then
  export ZSH_TMUX_AUTOSTARTED=true
  command tmux attach 2>/dev/null || command tmux new-session
fi

# FZF.
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

_gen_fzf_default_opts() {
  local base02="235" base2="254" base3="230" yellow="136" blue="33"
  export FZF_DEFAULT_OPTS="
    --color fg:-1,bg:-1,hl:$blue,fg+:$base2,bg+:$base02,hl+:$blue
    --color info:$yellow,prompt:$yellow,pointer:$base3,marker:$base3,spinner:$yellow
    --height 40% --exact --border --cycle --reverse --inline-info
    --bind 'ctrl-alt-u:preview-up'
    --bind 'ctrl-alt-d:preview-down'
    --bind 'f1:execute(less -f {}),ctrl-y:execute-silent(echo {} | pbcopy)+abort'
  "
}
_gen_fzf_default_opts

export FZF_COMPLETION_TRIGGER='~~'
export FZF_COMPLETION_OPTS='+c -x'
_fzf_compgen_path() { fd --hidden --follow --exclude ".git" . "$1"; }
_fzf_compgen_dir()  { fd --type d --hidden --follow --exclude ".git" . "$1"; }
export FZF_DEFAULT_COMMAND='fd --type f'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_OPTS="--preview 'tree -C {} | head -200'"

# Local + terminal-specific layers.
[ -f ~/.zshrc.local ] && source ~/.zshrc.local
[ -f "$HOME/GitHub/dotfiles/zsh/ghostty.zsh" ] && . "$HOME/GitHub/dotfiles/zsh/ghostty.zsh"

alias ff='fastfetch'
eval "$(rbenv init - zsh)"
fpath=(/Users/gregho/.docker/completions $fpath)

# bun completions
[ -s "/Users/gregho/.bun/_bun" ] && source "/Users/gregho/.bun/_bun"
