# Shared environment source of truth
[ -f "$HOME/GitHub/dotfiles/shell/.env.shared.sh" ] && . "$HOME/GitHub/dotfiles/shell/.env.shared.sh"

# NVM extras for bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"

# PYENV (ARM version)
if command -v /opt/homebrew/bin/pyenv 1>/dev/null 2>&1; then
  eval "$(/opt/homebrew/bin/pyenv init -)"
fi

# RBENV (ARM version)
if command -v /opt/homebrew/bin/rbenv 1>/dev/null 2>&1; then
  eval "$(/opt/homebrew/bin/rbenv init -)"
fi

# GOENV
if command -v goenv 1>/dev/null 2>&1; then
  eval "$(goenv init -)"
fi

# Alias
alias tmux-bl="tmux-bl.sh"

# Load local environment variables (tokens, secrets, machine-specific configs)
if [ -f "$HOME/.bash_profile.local" ]; then
  source "$HOME/.bash_profile.local"
fi
