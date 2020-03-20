export PATH="/opt/homebrew/bin:$PATH"  # ARM Homebrew
# 清華大學鏡像（最完整）
export HOMEBREW_BOTTLE_DOMAIN="https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles"
export HOMEBREW_API_DOMAIN="https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles/api"
export HOMEBREW_BREW_GIT_REMOTE="https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/brew.git"
export HOMEBREW_CORE_GIT_REMOTE="https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/homebrew-core.git"

export PATH="${PATH}:/Users/$USER/Scripts"
# Android
export ANDROID_HOME=/Users/$USER/Library/Android/sdk
export PATH=${PATH}:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools:$ANDROID_HOME/emulator
# export ANDROID_NDK=$ANDROID_HOME/android-ndk-r22b
export ANDROID_NDK=$ANDROID_HOME/ndk/21.4.7075529
# JAVA
# export JAVA_HOME=/Library/Java/JavaVirtualMachines/jdk1.8.0_162.jdk/Contents/Home/
# export JAVA_HOME=/Library/Java/JavaVirtualMachines/temurin-11.jdk/Contents/Home/
export JAVA_HOME=/Library/Java/JavaVirtualMachines/openjdk-17.jdk/Contents/Home/
# NVM
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# PYENV (ARM version)
if command -v /opt/homebrew/bin/pyenv 1>/dev/null 2>&1; then
  eval "$(/opt/homebrew/bin/pyenv init -)"
fi

# RBENV (ARM version)
if command -v /opt/homebrew/bin/rbenv 1>/dev/null 2>&1; then
  eval "$(/opt/homebrew/bin/rbenv init -)"
fi
# GO
# export PATH=$GOROOT/bin:$PATH
export PATH=$PATH:/Users/$USER/go/bin
export GOPATH=/Users/$USER/go
# FLUTTER
export PATH=${PATH}:/Users/$USER/Library/Flutter/bin
# GEM
# export PATH=${PATH}:/Users/$USER/.gem/ruby/2.6.0/bin  # Old system Ruby - use rbenv instead
# Alias
alias tmux-bl="tmux-bl.sh"
# Load local environment variables (tokens, secrets, machine-specific configs)
if [ -f "$HOME/.bash_profile.local" ]; then
    source "$HOME/.bash_profile.local"
fi
