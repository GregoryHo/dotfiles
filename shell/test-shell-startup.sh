#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SHARED_ENV="$ROOT_DIR/shell/.env.shared.sh"
ZSHRC="$ROOT_DIR/zsh/.zshrc"
ZPROFILE="$ROOT_DIR/zsh/.zprofile"
BASHRC="$ROOT_DIR/bash/.bashrc"
BASH_PROFILE="$ROOT_DIR/bash/.bash_profile"

contains_line() {
  local file="$1"
  local pattern="$2"
  awk -v pat="$pattern" 'index($0, pat) { found=1 } END { exit found ? 0 : 1 }' "$file"
}

contains_any_optional_source() {
  local file="$1"
  awk -v p1='. "$HOME/.local/bin/env"' \
      -v p2='. "$HOME/.cargo/env"' '
    index($0, p1) || index($0, p2) {
      found=1
    }
    END { exit found ? 0 : 1 }
  ' "$file"
}

printf '1) Validate shared env guard...\n'
contains_line "$SHARED_ENV" 'DOTFILES_ENV_SHARED_LOADED' || {
  echo "Missing DOTFILES_ENV_SHARED_LOADED guard in $SHARED_ENV" >&2
  exit 1
}

printf '2) Validate startup files source shared env...\n'
contains_line "$ZPROFILE" 'shell/.env.shared.sh' || {
  echo "Missing shared env source in $ZPROFILE" >&2
  exit 1
}
contains_line "$ZSHRC" 'shell/.env.shared.sh' || {
  echo "Missing shared env source in $ZSHRC" >&2
  exit 1
}
contains_line "$BASH_PROFILE" 'shell/.env.shared.sh' || {
  echo "Missing shared env source in $BASH_PROFILE" >&2
  exit 1
}
contains_line "$BASHRC" 'shell/.env.shared.sh' || {
  echo "Missing shared env source in $BASHRC" >&2
  exit 1
}

printf '3) Validate optional env scripts are not sourced unconditionally...\n'
if contains_any_optional_source "$ZSHRC"; then
  echo "Found unconditional optional env source in $ZSHRC" >&2
  exit 1
fi
if contains_any_optional_source "$BASHRC"; then
  echo "Found unconditional optional env source in $BASHRC" >&2
  exit 1
fi

printf '4) Validate idempotent shared env behavior (bash/zsh)...\n'
bash --noprofile --norc -c "
  set -e
  source '$SHARED_ENV'
  path_before=\"\$PATH\"
  source '$SHARED_ENV'
  [ \"\$PATH\" = \"\$path_before\" ]
  [ -n \"\$ANDROID_HOME\" ]
  [ -n \"\$JAVA_HOME\" ]
  [ \"\${DOTFILES_ENV_SHARED_LOADED:-}\" = \"1\" ]
"

zsh -f -c "
  set -e
  source '$SHARED_ENV'
  path_before=\"\$PATH\"
  source '$SHARED_ENV'
  [[ \"\$PATH\" == \"\$path_before\" ]]
  [[ -n \"\$ANDROID_HOME\" ]]
  [[ -n \"\$JAVA_HOME\" ]]
  [[ \"\${DOTFILES_ENV_SHARED_LOADED:-}\" == \"1\" ]]
"

printf '5) Validate stow deployment (symlinks in $HOME)...\n'
check_symlink() {
  local target="$1"
  local hint="$2"
  if [[ ! -L "$target" ]]; then
    echo "Missing symlink: $target" >&2
    echo "  Run: cd \"$ROOT_DIR\" && stow $hint" >&2
    return 1
  fi
  if [[ ! -e "$target" ]]; then
    local broken
    broken="$(readlink "$target")"
    echo "Broken symlink: $target -> $broken" >&2
    echo "  Run: cd \"$ROOT_DIR\" && stow -R $hint" >&2
    return 1
  fi
  return 0
}

deployment_ok=0
check_symlink "$HOME/.zprofile"        zsh  || deployment_ok=1
check_symlink "$HOME/.zshrc"           zsh  || deployment_ok=1
check_symlink "$HOME/.zshrc.local"     zsh  || deployment_ok=1
check_symlink "$HOME/.bash_profile"    bash || deployment_ok=1
check_symlink "$HOME/.bashrc"          bash || deployment_ok=1
check_symlink "$HOME/.tmux.conf.local" tmux || deployment_ok=1
[[ $deployment_ok -eq 0 ]] || exit 1

echo "All shell startup checks passed."
