[ -f ~/.fzf.bash ] && source ~/.fzf.bash

# Shared environment source of truth (required for non-login bash shells).
[ -f "$HOME/GitHub/dotfiles/shell/.env.shared.sh" ] && . "$HOME/GitHub/dotfiles/shell/.env.shared.sh"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
