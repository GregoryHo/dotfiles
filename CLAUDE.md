# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

Personal dotfiles for a macOS (ARM) development environment. Each tool owns a directory with base configs and optional `.local` override files for machine-specific customization. `.local` files are gitignored and may contain secrets.

## Deployment

Uses GNU Stow. Each top-level directory is a stow package, symlinked relative to `$HOME`. For XDG configs, the `config/` package maps to `~/.config/`.

Stow packages: `bash/`, `config/`, `fzf/`, `git/`, `nvim/`, `shell/` (not stowed — sourced), `tmux/`, `vim/`, `zsh/`

```bash
# Deploy all packages (from repo root)
stow bash config fzf git nvim tmux vim zsh

# Re-deploy a single package (adopt existing files)
stow -R zsh
```

## Validation

```bash
shell/test-shell-startup.sh   # Verify shared-env sourcing, guards, and idempotency
```

There is no build system, linter, or test framework beyond this script. Run it after any change to shell startup files.

## Shell Environment Architecture

All shared exports (PATH, XDG_CONFIG_HOME, Homebrew mirrors, Android, Java, Go, Flutter, Cargo) live in a single source of truth:

```
shell/.env.shared.sh          # Idempotent (DOTFILES_ENV_SHARED_LOADED guard)
```

Every shell startup file sources it with an existence guard:

```
zsh/.zprofile      ─┐
zsh/.zshrc         ─┤── all source shell/.env.shared.sh
bash/.bash_profile ─┤
bash/.bashrc       ─┘
```

This ensures both login and non-login shells (zsh and bash) get the same environment. The load order is:

1. `shell/.env.shared.sh` - exports and bootstrap only, no aliases/functions
2. `zsh/.zprofile` / `bash/.bash_profile` - login-shell init (version managers, local overrides)
3. `zsh/.zshrc` / `bash/.bashrc` - interactive config (Oh My Zsh, FZF, lazy loading, aliases)
4. `zsh/.zshrc.local` / `bash/.bash_profile.local` - machine-specific (gitignored)

### Rules When Editing Shell Files

- **Never duplicate shared exports** in shell-specific files. Add them to `shell/.env.shared.sh`.
- **Guard optional sources** with `[ -f "..." ] && . "..."` — never source a file unconditionally.
- **Keep `.env.shared.sh` idempotent** — sourcing it twice must not change PATH or variables.
- Run `shell/test-shell-startup.sh` after changes to verify.
- See `shell/SHELL_STARTUP_CONTRACT.md` for the full startup responsibility matrix.

## Configuration Override Pattern

Most tools follow: base config + `.local` override.

| Tool  | Base                  | Local override           |
|-------|-----------------------|--------------------------|
| Zsh   | `zsh/.zshrc`          | `zsh/.zshrc.local`       |
| Bash  | `bash/.bash_profile`  | `~/.bash_profile.local`  |
| Vim   | `vim/.vimrc`          | `vim/.vimrc.local`       |
| Vim plugins | `vim/.vimrc.bundles` | `vim/.vimrc.bundles.local` |
| Tmux  | Oh My Tmux base       | `tmux/.tmux.conf.local`  |
| Git   | `git/.gitconfig`      | —                        |
| FZF   | `fzf/.fzf.zsh`, `fzf/.fzf.bash` | —             |

## Config Directory (`config/`)

XDG-style configs in `~/.config/`. Lazygit and tmux-powerline are directory symlinks; karabiner is deployed separately.

| Tool            | Path                        | Notes                                    |
|-----------------|-----------------------------|------------------------------------------|
| Lazygit         | `config/lazygit/`           | Tokyonight Storm theme, safety defaults; `state.yml` gitignored |
| Karabiner       | `config/karabiner/`         | macOS keyboard remapping rules           |
| tmux-powerline  | `config/tmux-powerline/`    | Custom theme + segment config (see Tmux) |
| Neofetch        | `config/neofetch/`          | Custom ASCII art + display config        |
| Menus           | `config/menus/`             | XDG application menu merge rules         |

## FZF Helper Pattern

All fzf-based interactive pickers in `zsh/.zshrc.local` share a common UI via:

- `dot_fzf_ui()` — wrapper that sets consistent fzf flags (height, border, reverse, highlight-line)
- `dot_require_fzf()` — guard that errors if fzf is missing

Every picker function uses tab-delimited rows where column 1 is the machine-readable key and column 2+ is the display. They use `--delimiter=$'\t' --with-nth=2` and pipe through `cut -f1` to extract the selection. When adding new pickers, follow this same pattern.

Helper functions that produce picker rows are prefixed `dot_` (e.g., `dot_git_local_branch_rows`, `dot_tmux_session_rows`, `dot_wt_rows`).

## Key Function Groups (in zsh/.zshrc.local)

**Brew**: `bip` (install), `bup` (upgrade), `bcp` (uninstall), `bci`/`bcui` (cask install/uninstall with preview)

**Git**: `gla` (interactive log), `gcob`/`gcorb` (checkout local/remote branch), `gdb`/`gdfb` (delete branch safe/force)

**Worktree** (`wt*`): `wta` (add), `wtab` (add from branch picker), `wtr` (remove), `wtg` (go), `wtb` (go to base), `wtm` (merge), `wtp` (prune empty directories), `wtc` (add + env init + launch agent). Worktrees go in sibling directory `<repo>-worktrees/`.

**Tmux** (`t*`): `tl` (list sessions), `tx` (create/attach), `ts` (fzf session switch), `tk` (kill), `tsw` (window switch), `tw` (expand workspace: editor/agent/test/logs windows), `tsp` (pane switch)

**AI Agents**: `aa` (Claude), `ao` (Codex), `ag` (Gemini), with resume variants `aar`/`aor`/`agr`. All go through `dot_agent_cmd` wrapper. Tmux popup bindings: `prefix+A/O/G` to launch, `prefix+R` then `A/O/G` to resume.

## NVM Lazy Loading

In zsh, `nvm`/`node`/`npm`/`npx` are stub functions that self-replace on first call via `_nvm_lazy_load()`. The Oh My Zsh nvm/node/npm plugins are disabled in favor of this. The `load-nvmrc` chpwd hook auto-switches node versions based on `.nvmrc` files.

## Tmux

- Base framework: Oh My Tmux (`.tmux.conf` from gpakosz)
- All local overrides in `tmux/.tmux.conf.local`
- Theme: tmux-powerline with custom Tokyo Night Storm minimal theme (`config/tmux-powerline/config.sh`; built-in Oh My Tmux theme disabled)
- Plugins via tpm: tmux-resurrect, tmux-continuum, erikw/tmux-powerline
- Mouse on, vi mode keys, prefix is C-a (GNU Screen compatible)
- Plugin auto-update on launch/reload is disabled for faster startup

## Vim

- Plugin manager: vim-plug (bundles in `vim/.vimrc.bundles`, local additions in `.vimrc.bundles.local`)
- LSP: CoC (Conquer of Completion) with settings in `vim/coc-settings.json`
- 2-space indentation, system clipboard integration

## Neovim

- Based on kickstart.nvim; entry point `nvim/init.lua`
- Plugin manager: lazy.nvim (lock file `nvim/lazy-lock.json`)
- Custom plugins in `nvim/lua/custom/plugins/`; kickstart modules in `nvim/lua/kickstart/plugins/`
- LSP configured via mason.nvim (auto-install servers)
- Stowed to `~/.config/nvim`
