# GNU Stow Deployment

Symlink-based dotfile management where each top-level directory is an
independently deployable package.

## Why

Dotfiles need to live in a git repo but tools expect them in `$HOME` or
`~/.config/`. Copying files loses the git link. Manual symlinks don't scale.
GNU Stow automates the mapping: each directory becomes a "package" whose
contents are symlinked relative to a target (default: parent of stow dir, i.e.
`$HOME`).

## How It Works

Stow treats each top-level directory as a package. Running `stow zsh` from the
repo root creates symlinks in `$HOME` for every file inside `zsh/`:

```
stow zsh
  zsh/.zprofile  ──▶  ~/.zprofile
  zsh/.zshrc     ──▶  ~/.zshrc
```

### Package Map

```
dotfiles/                        $HOME
├── bash/                        │
│   ├── .bash_profile   ─────────┼──▶  ~/.bash_profile
│   └── .bashrc         ─────────┼──▶  ~/.bashrc
├── config/                      │
│   ├── lazygit/        ─────────┼──▶  ~/.config/lazygit/
│   ├── tmux-powerline/ ─────────┼──▶  ~/.config/tmux-powerline/
│   ├── karabiner/      ─────────┼──▶  ~/.config/karabiner/
│   ├── neofetch/       ─────────┼──▶  ~/.config/neofetch/
│   └── menus/          ─────────┼──▶  ~/.config/menus/
├── fzf/                         │
│   ├── .fzf.zsh       ─────────┼──▶  ~/.fzf.zsh
│   └── .fzf.bash      ─────────┼──▶  ~/.fzf.bash
├── git/                         │
│   ├── .gitconfig      ─────────┼──▶  ~/.gitconfig
│   └── .gitconfig-github ───────┼──▶  ~/.gitconfig-github
├── nvim/                        │
│   └── (entire tree)   ─────────┼──▶  ~/.config/nvim/
├── tmux/                        │
│   └── .tmux.conf.local ───────┼──▶  ~/.tmux.conf.local
├── vim/                         │
│   ├── .vimrc          ─────────┼──▶  ~/.vimrc
│   ├── .vimrc.bundles  ─────────┼──▶  ~/.vimrc.bundles
│   └── coc-settings.json ──────┼──▶  ~/.vim/coc-settings.json
├── zsh/                         │
│   ├── .zprofile       ─────────┼──▶  ~/.zprofile
│   └── .zshrc          ─────────┼──▶  ~/.zshrc
│                                │
├── shell/   ◀── NOT STOWED      │
│   └── .env.shared.sh          │   (sourced directly by path)
│                                │
└── docs/    ◀── NOT STOWED      │
    └── (you are here)           │
```

### The `config/` Package Trick

The `config/` directory maps to `~/.config/` because Stow preserves directory
structure relative to the target. Since the repo lives in `~/GitHub/dotfiles/`,
and the stow target is `$HOME` (one level up from repo... actually the default
parent), the `config/` directory inside the package creates symlinks at the
right XDG path:

```
dotfiles/config/lazygit/  ──stow──▶  ~/.config/lazygit/  (directory symlink)
```

This means lazygit and tmux-powerline configs are **directory symlinks**, not
individual file symlinks. Editing any file inside edits the repo copy directly.

### Why `shell/` Is Not Stowed

`shell/.env.shared.sh` is sourced by absolute path from every startup file:

```bash
[ -f "$HOME/GitHub/dotfiles/shell/.env.shared.sh" ] && \
  . "$HOME/GitHub/dotfiles/shell/.env.shared.sh"
```

It doesn't need to appear in `$HOME` — it's a shared library, not a user-facing
config file. Stowing it would create `~/.env.shared.sh`, which is misleading.

## Commands

```bash
# Deploy all packages (from repo root)
stow bash config fzf git nvim tmux vim zsh

# Re-deploy a single package (adopt existing files into repo)
stow -R zsh

# Dry run (preview what would be symlinked)
stow -n -v zsh
```

## Key Files

| File | Role |
|------|------|
| `bash/`, `zsh/`, etc. | Stow packages (top-level dirs) |
| `config/` | XDG configs → `~/.config/` |
| `shell/` | Sourced-only shared env (not stowed) |

## See Also

- [02-shell-environment.md](02-shell-environment.md) — how `shell/` is sourced
- [03-config-override-pattern.md](03-config-override-pattern.md) — base + `.local` layering
