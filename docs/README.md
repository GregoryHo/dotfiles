# Dotfiles Technique Documentation

Reference documentation for the architectural patterns and techniques in this
dotfiles repository. Each document describes **why** a technique exists, **how**
it works, and includes ASCII diagrams for visual clarity.

## Master Architecture

```
dotfiles/
├── bash/            ──stow──▶  ~/.bash_profile, ~/.bashrc
├── config/          ──stow──▶  ~/.config/{lazygit,tmux-powerline,karabiner,...}
├── fzf/             ──stow──▶  ~/.fzf.zsh, ~/.fzf.bash
├── git/             ──stow──▶  ~/.gitconfig, ~/.gitconfig-github
├── nvim/            ──ln -s──▶  ~/.config/nvim/  (manual symlink)
├── shell/           (sourced by all shells — never stowed)
├── tmux/            ──stow──▶  ~/.tmux.conf.local
├── vim/             ──stow──▶  ~/.vimrc, ~/.vim/
├── zsh/             ──stow──▶  ~/.zprofile, ~/.zshrc
└── docs/            (you are here)
```

## Technique Index

### Foundation

| # | Technique | Summary |
|---|-----------|---------|
| [01](01-stow-deployment.md) | GNU Stow Deployment | Package-per-tool symlink management |
| [02](02-shell-environment.md) | Shell Environment Architecture | Single source of truth with idempotency guard |
| [03](03-config-override-pattern.md) | Configuration Override Pattern | Base config + `.local` layering |
| [04](04-nvm-lazy-loading.md) | NVM Lazy Loading | Eager PATH + stub function for instant startup |

### Interactive Tooling

| # | Technique | Summary |
|---|-----------|---------|
| [05](05-fzf-picker-pattern.md) | FZF Picker Pattern | Tab-delimited row protocol for all pickers |
| [06](06-tmux-agent-orchestration.md) | Tmux Agent Orchestration | Hybrid flow: full sessions vs quick-ask popups |
| [07](07-quick-ask-repl.md) | Quick-Ask REPL | Background agent Q&A with live preview |
| [08](08-agent-dashboard.md) | Agent Dashboard | Live monitoring of all running agents |
| [09](09-agent-status-segment.md) | Agent Status Segment | Powerline segment showing agent count |

### Configuration & Workflow

| # | Technique | Summary |
|---|-----------|---------|
| [10](10-git-identity.md) | Git Identity Management | `includeIf` routing for multi-identity |
| [11](11-worktree-workflow.md) | Worktree Workflow | Sibling-directory worktree lifecycle |
| [12](12-neovim.md) | Neovim Configuration | kickstart.nvim + lazy.nvim + custom plugins |
| [13](13-safety-defaults.md) | Safety Defaults | Defensive configuration inventory |

## System Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                        Terminal Session                          │
│                                                                  │
│  ┌─────────────┐    ┌──────────────────────────────────────┐    │
│  │  Zsh / Bash  │───▶│  shell/.env.shared.sh (idempotent)  │    │
│  │  startup     │    │  PATH, XDG, Homebrew, SDK paths      │    │
│  └──────┬──────┘    └──────────────────────────────────────┘    │
│         │                                                        │
│         ▼                                                        │
│  ┌──────────────┐    ┌────────────────────────────────────┐     │
│  │  Oh My Zsh    │    │  .local overrides (gitignored)     │     │
│  │  + Plugins    │    │  Secrets, machine-specific config   │     │
│  └──────┬───────┘    └────────────────────────────────────┘     │
│         │                                                        │
│         ▼                                                        │
│  ┌─────────────────────────────────────────────┐                │
│  │  Tmux (auto-start)                           │                │
│  │  ┌──────────┐ ┌──────────┐ ┌──────────────┐ │                │
│  │  │  Editor   │ │  Agent   │ │  Quick-Ask   │ │                │
│  │  │  (nvim)   │ │  Windows │ │  Popups      │ │                │
│  │  └──────────┘ └────┬─────┘ └──────┬───────┘ │                │
│  │                     │              │          │                │
│  │              ┌──────▼──────────────▼──────┐  │                │
│  │              │  Agent Dashboard (tsa)      │  │                │
│  │              │  + Status Segment (C/O/G)   │  │                │
│  │              └─────────────────────────────┘  │                │
│  │                                               │                │
│  │  ┌──────────┐ ┌──────────┐ ┌──────────────┐ │                │
│  │  │ Lazygit  │ │ Worktrees│ │  FZF Pickers │ │                │
│  │  │ (delta)  │ │  (wt*)   │ │  (dot_*)     │ │                │
│  │  └──────────┘ └──────────┘ └──────────────┘ │                │
│  └─────────────────────────────────────────────┘                │
└─────────────────────────────────────────────────────────────────┘
```

## Reading Order

Start with [01-stow-deployment](01-stow-deployment.md) and
[02-shell-environment](02-shell-environment.md) — everything else builds on them.
The agent system (docs 06-09) forms a cohesive subsystem best read together.
