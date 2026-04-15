# Shared login-shell environment for zsh/bash.
# Keep this file shell-agnostic and focused on exports/bootstrap only.

# Prevent duplicate setup within the same shell.
# NOT exported — child shells (e.g. tmux panes) must re-run this file because
# macOS path_helper (/etc/zprofile) reorders PATH on every shell startup.
if [ -n "${DOTFILES_ENV_SHARED_LOADED:-}" ]; then
  return 0
fi
DOTFILES_ENV_SHARED_LOADED=1

# XDG base directories
export XDG_CONFIG_HOME="$HOME/.config"

# Core PATH
export PATH="/opt/homebrew/bin:$PATH"
export PATH="$PATH:/usr/local/bin"
export PATH="$PATH:/Users/$USER/Scripts"

# Homebrew mirrors
export HOMEBREW_BOTTLE_DOMAIN="https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles"
export HOMEBREW_API_DOMAIN="https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles/api"
export HOMEBREW_BREW_GIT_REMOTE="https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/brew.git"
export HOMEBREW_CORE_GIT_REMOTE="https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/homebrew-core.git"

# Android
export ANDROID_HOME="/Users/$USER/Library/Android/sdk"
export PATH="$PATH:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools:$ANDROID_HOME/emulator"
export ANDROID_NDK="$ANDROID_HOME/ndk/21.4.7075529"

# Java
export JAVA_HOME="/Library/Java/JavaVirtualMachines/openjdk-17.jdk/Contents/Home/"

# Go
export GOENV_ROOT="$HOME/.goenv"
export PATH="$GOENV_ROOT/bin:$PATH"
export GOPATH="$HOME/go"
export PATH="$GOPATH/bin:$PATH"

# Flutter
export PATH="$PATH:/Users/$USER/Library/Flutter/bin"

# Opencode
export PATH="$HOME/.opencode/bin:$PATH"

# Bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# Antigravity
export PATH="$HOME/.antigravity/antigravity/bin:$PATH"

# Obsidian CLI
export PATH="$PATH:/Applications/Obsidian.app/Contents/MacOS"

# Local/cargo env scripts (if present)
[ -f "$HOME/.local/bin/env" ] && . "$HOME/.local/bin/env"
[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"

# Deduplicate PATH (keeps first occurrence, preserves order).
# Needed because child shells inherit PATH then re-prepend above entries.
PATH="$(printf '%s' "$PATH" | awk -v RS=: -v ORS=: '!seen[$0]++')"
PATH="${PATH%:}"
export PATH

# Ensure node is available for non-interactive login shells (e.g. zsh -lc, env node shebang).
export NVM_DIR="$HOME/.nvm"
if ! command -v node >/dev/null 2>&1; then
  if [ -s "$NVM_DIR/nvm.sh" ]; then
    . "$NVM_DIR/nvm.sh"
    nvm use --silent default >/dev/null 2>&1 || true
  fi
fi
