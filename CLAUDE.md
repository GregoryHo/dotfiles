# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a personal dotfiles repository containing modular configuration files for a macOS development environment. Each tool has its own directory with core configuration files and optional `.local` override files for machine-specific customizations.

### Directory Structure

- `bash/` - Bash shell configuration and environment setup
- `zsh/` - Zsh shell with Oh My Zsh and PowerLevel10k theme
- `vim/` - Vim editor with vim-plug plugin manager and CoC LSP
- `git/` - Git configuration with Delta pager and custom color schemes  
- `tmux/` - Tmux terminal multiplexer with Oh My Tmux base configuration
- `fzf/` - FZF fuzzy finder with custom Solarized color scheme
- `config/` - System-level configurations (Karabiner, Neofetch)

## Key Architecture Patterns

### Configuration Override System
Most tools follow a pattern where:
- Base configuration is in the main dotfile (e.g., `.vimrc`, `.zshrc`)
- Machine-specific overrides go in `.local` files (e.g., `.vimrc.local`, `.zshrc.local`)
- This allows shared base configs while accommodating different environments

### Shell Environment Chain
The shell environment loads in this order:
1. `bash/.bash_profile` - Core environment variables and PATH setup
2. `zsh/.zshrc` - Zsh-specific configuration (sources bash_profile)
3. `zsh/.zshrc.local` - Machine-specific Zsh overrides

## Development Environment

### Core Tools Setup
- **Homebrew**: Configured with Tsinghua University mirrors for faster downloads in China
- **Node.js**: Managed via NVM with completion support
- **Python**: Managed via PyEnv (ARM Homebrew version)
- **Ruby**: Managed via RBenv (ARM Homebrew version)
- **Java**: OpenJDK 17 configured as JAVA_HOME
- **Go**: GOPATH and binaries in user's go directory
- **Android**: Full SDK setup with emulator and NDK paths
- **Flutter**: Added to PATH for mobile development

### Key Environment Variables
```bash
ANDROID_HOME=/Users/$USER/Library/Android/sdk
JAVA_HOME=/Library/Java/JavaVirtualMachines/openjdk-17.jdk/Contents/Home/
GOPATH=/Users/$USER/go
```

## Tool-Specific Configuration

### Zsh + Oh My Zsh
- **Theme**: PowerLevel10k with custom prompt segments (battery, time, directory, git status)
- **Plugins**: zsh-syntax-highlighting, docker, git, nvm, node, npm, kubectl, minikube, tmux, react-native
- **Features**: Auto-start tmux, custom history settings, FZF integration
- **Colors**: Custom Solarized-based theme throughout

### Vim Configuration
- **Plugin Manager**: vim-plug (located in `~/.vim/bundle/`)
- **Plugin Loading**: Bundles defined in `.vimrc.bundles`, local additions in `.vimrc.bundles.local`
- **LSP Support**: CoC (Conquer of Completion) for modern IDE features
- **Key Plugins**: NERDTree, fugitive, syntastic, vim-tmux-navigator, gitgutter
- **Settings**: 2-space indentation, line numbers, system clipboard integration

### Git Configuration
- **Pager**: Delta with Monokai Extended theme for enhanced diffs
- **User**: gregory_ho@tengyuntech.com
- **Editor**: Vim as default
- **Colors**: Custom color schemes for branches, diffs, and status
- **Global Ignore**: Uses `.gitignore_global`

### Tmux Setup
- **Base**: Oh My Tmux configuration framework
- **Overrides**: Local customizations in `.tmux.conf.local`
- **Features**: 256-color support, GNU Screen compatible prefix (C-a)
- **Integration**: Auto-start via Zsh plugin, vim navigator support

### FZF Integration  
- **Color Scheme**: Custom Solarized Dark theme
- **Trigger**: `~~` instead of default `**`
- **Backend**: Uses `fd` for file searching instead of find
- **Bindings**: Custom preview bindings for file exploration
- **Commands**: Enhanced CTRL-T and ALT-C with previews

## Common Workflows

### Making Configuration Changes
1. Edit base configuration files for universal changes
2. Use `.local` files for machine-specific modifications
3. Source or restart shell to apply changes
4. For vim plugins: edit `.vimrc.bundles.local`, run `:PlugInstall`

### Environment Management
- Node versions: `nvm use <version>` or `nvm install <version>`
- Python versions: `pyenv global <version>` or `pyenv local <version>`
- Ruby versions: `rbenv global <version>` or `rbenv local <version>`

### Development Setup on New Machine
1. Clone this repository
2. Create symbolic links from home directory to these dotfiles
3. Install required tools (Homebrew, Oh My Zsh, vim-plug, etc.)
4. Create `.local` override files as needed
5. Source shell configuration or restart terminal

## Security Notes
- Contains API tokens/keys in bash/.bash_profile (JENKINS_TOKEN, NOTION_TOKEN, CONTEXT7_API_KEY)
- These should be moved to `.local` files or environment-specific configuration
- Karabiner configuration includes keyboard remapping rules

## Special Features
- **Terminal**: Automatic tmux session management with iTerm2 integration
- **Prompt**: Rich PowerLevel10k prompt with battery status, git info, and system load
- **Search**: Comprehensive FZF setup with fd backend for fast file navigation
- **System Info**: Neofetch automatically runs on shell startup for system overview