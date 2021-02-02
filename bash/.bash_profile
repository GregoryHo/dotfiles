export PATH="/usr/local/bin:$PATH"
# Android
export ANDROID_HOME=/Users/$USER/Library/Android/sdk
export PATH=${PATH}:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools:$ANDROID_HOME/emulator
export ANDROID_NDK=$ANDROID_HOME/android-ndk-r10e
# NVM
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
# Go
export GOROOT=/usr/local/Cellar/go
export PATH=$GOROOT/bin:$PATH
export GOPATH=/Users/$USER/go
# Flutter
export PATH=${PATH}:/Users/$USER/Library/Flutter/bin
