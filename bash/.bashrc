[ -f ~/.fzf.bash ] && source ~/.fzf.bash

# Shared environment source of truth (required for non-login bash shells).
[ -f "$HOME/GitHub/dotfiles/shell/.env.shared.sh" ] && . "$HOME/GitHub/dotfiles/shell/.env.shared.sh"
