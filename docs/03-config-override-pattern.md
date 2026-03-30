# Configuration Override Pattern

Base configs live in the repo (public, versioned). Machine-specific overrides
live in `.local` files (gitignored, private).

## Why

Dotfiles are personal but not entirely private. You want to share your Vim
settings and tmux keybindings publicly, but not your work email, signing keys,
or internal tool paths. The override pattern solves this:

- **Base config**: tracked in git, safe to push to GitHub
- **`.local` override**: gitignored, loaded last, can override anything

This also enables machine-specific customization (different PATH on work vs
personal laptop) without maintaining separate branches.

## How It Works

### The Layering Model

```
┌─────────────────────────────────────────────────────────────────┐
│                     Effective Configuration                      │
│                                                                  │
│  ┌─────────────────────────┐  ┌──────────────────────────────┐  │
│  │  Base Config (tracked)   │  │  .local Override (gitignored) │  │
│  │                          │  │                               │  │
│  │  Public settings         │──▶│  Machine-specific paths      │  │
│  │  Shared keybindings      │  │  Work identities/tokens       │  │
│  │  Theme/appearance        │  │  Secret environment vars      │  │
│  │  Plugin lists            │  │  Local tool integrations      │  │
│  └─────────────────────────┘  └──────────────────────────────┘  │
│                                                                  │
│              Base loads first ──▶ .local loads last              │
│              .local can override or extend anything              │
└─────────────────────────────────────────────────────────────────┘
```

### Override Map

```
Tool     Base (tracked)             Override (gitignored)         Loading Mechanism
─────    ──────────────             ─────────────────────         ─────────────────
Zsh      zsh/.zshrc                 zsh/.zshrc.local              source at end of .zshrc
Bash     bash/.bash_profile         ~/.bash_profile.local         source at end of .bash_profile
Vim      vim/.vimrc                 vim/.vimrc.local              source at end of .vimrc
Vim      vim/.vimrc.bundles         vim/.vimrc.bundles.local      source at end of .vimrc.bundles
Tmux     tmux/.tmux.conf.local      (is the local override)       Oh My Tmux sources it
Git      git/.gitconfig             ~/.gitconfig.local            [include] directive
Shell    shell/.env.shared.sh       $HOME/.local/bin/env          source (guarded)
```

### Loading Mechanisms

**Shell files** — source at end of file:
```bash
# At the end of zsh/.zshrc:
[ -f "$HOME/.zshrc.local" ] && . "$HOME/.zshrc.local"
```

**Git** — include directive:
```ini
# In git/.gitconfig:
[include]
    path = ~/.gitconfig.local
```

**Vim** — source command:
```vim
" At the end of .vimrc:
if filereadable(expand("~/.vimrc.local"))
  source ~/.vimrc.local
endif
```

**Tmux** — Oh My Tmux convention:
The base `.tmux.conf` (Oh My Tmux) sources `.tmux.conf.local` automatically.
In this repo, `tmux/.tmux.conf.local` IS the customization file.

### What Goes Where

```
Tracked (base)                              Gitignored (.local)
──────────────                              ────────────────────
Oh My Zsh plugins list                      API tokens, secrets
FZF trigger/source config                   Work-specific aliases
Git delta pager settings                    Corporate git identity
Tmux keybindings                            Machine-specific PATHs
Vim plugin list                             Local plugin additions
NVM lazy loading                            Proxy/VPN settings
Agent dashboard functions                   Auth tokens for agents
```

### The Git Special Case

Git uses `includeIf` for directory-based identity switching, which is a more
sophisticated version of the override pattern. See
[10-git-identity.md](10-git-identity.md) for details.

## Key Files

| File | Role |
|------|------|
| `zsh/.zshrc` | Sources `~/.zshrc.local` at end |
| `bash/.bash_profile` | Sources `~/.bash_profile.local` at end |
| `vim/.vimrc` | Sources `~/.vimrc.local` at end |
| `git/.gitconfig` | Includes `~/.gitconfig.local` |
| `tmux/.tmux.conf.local` | Is itself the override file for Oh My Tmux |
| `.gitignore` | Excludes all `.local` files |

## See Also

- [02-shell-environment.md](02-shell-environment.md) — the shared env and its optional sources
- [10-git-identity.md](10-git-identity.md) — `includeIf` identity routing (advanced override)
