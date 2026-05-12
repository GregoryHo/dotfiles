# GNU Stow Deployment

Symlink-based dotfile management where each top-level directory is an
independently deployable package.

## Why

Dotfiles need to live in a git repo but tools expect them in `$HOME` or
`~/.config/`. Copying files loses the git link. Manual symlinks don't scale.
GNU Stow automates the mapping: each directory becomes a "package" whose
contents are symlinked relative to a target directory. Since this repo lives in
`~/GitHub/dotfiles/` (not directly under `$HOME`), all stow commands require
`-t $HOME` to target the home directory.

## How It Works

Stow treats each top-level directory as a package. Running `stow -t $HOME zsh`
from the repo root creates symlinks in `$HOME` for every file inside `zsh/`:

```
stow -t $HOME zsh
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
│   ├── alacritty/      ─────────┼──▶  ~/.config/alacritty/
│   ├── ghostty/        ─────────┼──▶  ~/.config/ghostty/
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
│   └── (entire tree)   ── ln ───┼──▶  ~/.config/nvim/  (manual symlink)
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
structure relative to the target. With `-t $HOME`, the `config/` directory
inside the package creates symlinks at the right XDG path:

```
dotfiles/config/lazygit/  ──stow -t $HOME──▶  ~/.config/lazygit/  (directory symlink)
```

This means lazygit and tmux-powerline configs are **directory symlinks**, not
individual file symlinks. Editing any file inside edits the repo copy directly.

### Manual Symlinks

Not everything is stow-managed. Some packages need non-standard target paths:

```
nvim/                  ── ln -s ──▶  ~/.config/nvim       (entire directory)
nvm-default-packages   ── ln -s ──▶  ~/.nvm/default-packages
```

Neovim's config must live at `~/.config/nvim/` but the package has `init.lua`
at its root (no `.config/nvim` subpath), so a direct directory symlink is used
instead of stow. Similarly, `nvm-default-packages` targets `~/.nvm/`, which is
outside `$HOME`'s direct children.

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
# Deploy all stow packages (from repo root, targeting $HOME)
stow -t $HOME bash config fzf git tmux vim zsh

# Re-deploy a single package (unstow + stow, fixes stale symlinks)
stow -t $HOME -R zsh

# Dry run (preview what would be symlinked)
stow -t $HOME -n -v zsh

# Manual symlinks (not stow-managed)
ln -s ~/GitHub/dotfiles/nvim ~/.config/nvim
ln -s ~/GitHub/dotfiles/nvm-default-packages ~/.nvm/default-packages
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
