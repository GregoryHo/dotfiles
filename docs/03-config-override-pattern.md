# Configuration Override Pattern

Base configs live in the repo (public, versioned). Overrides use `.local` files
— some tracked (shareable customizations), some gitignored (secrets, machine-specific).

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
┌───────────────────────────────────────────────────────────────────────┐
│                       Effective Configuration                         │
│                                                                       │
│  ┌──────────────────┐  ┌───────────────────┐  ┌───────────────────┐  │
│  │ Base Config       │  │ Tracked .local     │  │ Home-level .local  │  │
│  │ (tracked)         │  │ (tracked, in-repo) │  │ (gitignored)       │  │
│  │                   │  │                    │  │                    │  │
│  │ Framework setup   │──▶│ Shareable customs  │──▶│ Secrets/tokens    │  │
│  │ Plugin lists      │  │ Aliases, functions │  │ Work identity      │  │
│  │ Core settings     │  │ FZF pickers        │  │ Machine paths      │  │
│  └──────────────────┘  └───────────────────┘  └───────────────────┘  │
│                                                                       │
│         Base loads first ──▶ .local loads last                        │
│         .local can override or extend anything                        │
└───────────────────────────────────────────────────────────────────────┘
```

### Override Map

```
Tool     Base (tracked)             Override                      Tracked?  Loading Mechanism
─────    ──────────────             ────────                      ────────  ─────────────────
Zsh      zsh/.zshrc                 zsh/.zshrc.local              YES       source at end of .zshrc
Bash     bash/.bash_profile         ~/.bash_profile.local         NO        source at end of .bash_profile
Vim      vim/.vimrc                 vim/.vimrc.local              YES       source at end of .vimrc
Vim      vim/.vimrc.bundles         vim/.vimrc.bundles.local      YES       source at end of .vimrc.bundles
Tmux     tmux/.tmux.conf.local      (is the local override)       YES       Oh My Tmux sources it
Git      git/.gitconfig             ~/.gitconfig.local            NO        [include] directive
Shell    shell/.env.shared.sh       $HOME/.local/bin/env          NO        source (guarded)
```

**Important distinction**: Some `.local` files are tracked in this repo (they
contain shareable customizations like aliases and FZF pickers). Home-level
overrides (`~/.*local`) are gitignored and may contain secrets. **Never put
secrets in tracked `.local` files.**

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
Tracked base files                Tracked .local files             Gitignored home-level .local
──────────────────                ────────────────────             ────────────────────────────
Oh My Zsh plugins list            Aliases & shell functions        API tokens, secrets
FZF trigger/source config         FZF picker definitions           Corporate git identity
Git delta pager settings          Agent dashboard functions         Machine-specific PATHs
Tmux keybindings                  Custom vim settings              Proxy/VPN settings
Vim plugin list                   Tmux local overrides             Auth tokens for agents
NVM lazy loading                  Brew helpers                     Local plugin additions
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
