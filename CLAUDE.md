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
| Git   | `git/.gitconfig`      | `~/.gitconfig.local`     |
| FZF   | `fzf/.fzf.zsh`, `fzf/.fzf.bash` | —             |

### Git Pager & Diff

Git uses [delta](https://github.com/dandavella/delta) as the pager (`git/.gitconfig` `[pager]` section) with Monokai Extended theme. Preserve the `[pager]` and `[delta]` sections when editing `.gitconfig`. Grep is configured with `--heading --line-number --extended-regexp`.

### Git Identity Overrides

GitHub identity is tracked in `git/.gitconfig-github` (public info, safe to commit). Work identities (e.g. GitLab) are configured via `~/.gitconfig.local` using `includeIf` directives that point to untracked identity files like `~/.gitconfig-gitlab`. This keeps work directory paths and corporate identities out of the public repo.

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

**Tmux** (`t*`): `tl` (list sessions), `tx` (create/attach), `ts` (fzf session switch), `tk` (kill), `tsw` (window switch), `tw` (expand workspace: editor/agent/test/logs windows), `tsp` (pane switch), `tsa` (agent dashboard: fzf picker with live preview, send commands, ctrl-x stop), `tla` (list all agents)

**AI Agents**: `aa` (Claude), `ao` (Codex), `ag` (Gemini), with resume variants `aar`/`aor`/`agr`. All go through `dot_agent_cmd` wrapper. Tmux bindings: `prefix+A/O/G` (uppercase) launch full interactive sessions in dedicated windows, `prefix+a/o/g` (lowercase) open async quick-ask REPL popups — an fzf-based Q&A loop where questions run in the background and answers stream into a live preview pane. `prefix+R` then `A/O/G` to resume. Quick-ask via `dot_quick_ask <agent>` function.

## Zsh Interactive Config

- Theme: Powerlevel10k with battery, time, dir, vcs (left) and execution time, jobs, ram, load (right)
- Oh My Zsh plugins: `git`, `docker`, `kubectl`, `minikube`, `react-native`, `zsh-syntax-highlighting`, `tmux` (auto-start enabled)
- FZF trigger sequence is `~~` (not default `**`); source is `fd --type f`
- `vim`/`vi`/`mvim` are all aliased to `nvim`

## NVM Lazy Loading

In zsh, `nvm`/`node`/`npm`/`npx` are stub functions that self-replace on first call by inlining `. "$NVM_DIR/nvm.sh"`. The Oh My Zsh nvm/node/npm plugins are disabled in favor of this. The `load-nvmrc` chpwd hook auto-switches node versions based on `.nvmrc` files.

Global packages that should persist across Node versions are listed in `nvm-default-packages` (symlinked to `~/.nvm/default-packages`). NVM auto-installs these on every `nvm install`. Edit this file when adding/removing persistent global tools.

## Tmux

- Base framework: Oh My Tmux (`.tmux.conf` from gpakosz)
- All local overrides in `tmux/.tmux.conf.local`
- Theme: tmux-powerline with custom Tokyo Night Storm minimal theme (`config/tmux-powerline/config.sh`; built-in Oh My Tmux theme disabled)
- Plugins via tpm: tmux-resurrect, tmux-continuum, erikw/tmux-powerline
- Mouse on, vi mode keys, prefix is C-a (GNU Screen compatible)
- Plugin auto-update on launch/reload is disabled for faster startup
- Key custom bindings: `prefix+T` (agent dashboard popup), `prefix+L` (lazygit), `prefix+m/M` (mouse toggle/status)
- Layer 2 enhancements:
  - `prefix+E`: open scrollback in Neovim (read-only editor, like Zellij's scrollback)
  - `tmux-thumbs` plugin: hint-based selection for URLs, paths, SHAs (like Vimium for terminal)
  - `dot_notify_agent`: macOS notification (Glass sound) when an agent process exits
  - `agent_status` powerline segment: shows running agent count (C/O/G) in status bar, hidden when none active

## Vim

- Plugin manager: vim-plug (bundles in `vim/.vimrc.bundles`, local additions in `.vimrc.bundles.local`)
- LSP: CoC (Conquer of Completion) with settings in `vim/coc-settings.json`
- 2-space indentation, system clipboard integration

## Neovim

- Based on kickstart.nvim; entry point `nvim/init.lua`
- Plugin manager: lazy.nvim (lock file `nvim/lazy-lock.json`)
- Custom plugins in `nvim/lua/custom/plugins/`: `git.lua` (diffview, gitsigns), `filesystem.lua` (neo-tree)
- Kickstart modules in `nvim/lua/kickstart/plugins/` (autopairs, indent, lint, debug, gitsigns, neo-tree)
- LSP configured via mason.nvim (auto-install servers)
- Leader key: `<space>` (Vim uses `,`)
- Stowed to `~/.config/nvim`

## Gotchas

- **GVM is intentionally disabled** in `zsh/.zshrc` — it caused `cd` slowdown. Don't re-enable without testing.
- **Lazygit has force-push disabled** (`disableForcePushing: true` in `config/lazygit/config.yml`) — this is intentional safety.
- **OrbStack shell integration** is sourced in `zsh/.zprofile` — don't remove without checking container workflows.
- **Tmux auto-start is on** (`ZSH_TMUX_AUTOSTART=true` in `zsh/.zshrc`) — every new zsh terminal joins tmux.
- **`rm` is aliased to `rm -i`** in `zsh/.zshrc.local` — interactive confirmation by default.
