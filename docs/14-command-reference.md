# Command Reference

Flat inventory of every user-facing function, alias, and tmux binding defined
in this repo. For *why* a command exists or *how* the underlying pattern works,
see the technique docs (`01-*.md` through `13-*.md`).

**Source locations:**
- Shell functions / aliases: `zsh/.zshrc.local`
- Tmux key bindings: `tmux/.tmux.conf.local`
- Canonical name list (OMZ alias shadow guard): `zsh/.zshrc.local:666`

> The **Definition** column gives `file:line` for fast jumping. Keep it accurate.

---

## Tmux — session / window / pane

| Name | Command | Behavior | Definition |
|------|---------|----------|------------|
| `tl` | `tl` | List all tmux sessions in a table (marker, state, name, clients, wins) | `zsh/.zshrc.local:1077` |
| `tx` | `tx [name]` | Create new session or switch to existing. Default session name = `basename $PWD`; default window name = `main`. On create, sets `@project_path = $PWD` for consistent agent-launch context | `zsh/.zshrc.local:1088` |
| `ts` | `ts` | fzf picker for switching to another session | `zsh/.zshrc.local:1101` |
| `tk` | `tk [name]` | Kill session (fzf picker if no arg) | `zsh/.zshrc.local:1126` |
| `tsw` | `tsw` | fzf picker for switching window across all sessions | `zsh/.zshrc.local:1148` |
| `tsp` | `tsp` | fzf picker for switching pane across all sessions | `zsh/.zshrc.local:1378` |
| `tw` | `tw [name]` | Expand current session into multi-window workspace: editor / agent-claude / test / logs. Sets `@project_path = $root` on every window (idempotent on re-run) | `zsh/.zshrc.local:1284` |

## Tmux — AI agent management

| Name | Command | Behavior | Definition |
|------|---------|----------|------------|
| `tla` | `tla` | List all running AI agents (table) | `zsh/.zshrc.local:1657` |
| `tsa` | `tsa` | Agent workspace popup. Bindings: `enter`=goto pane · `ctrl-n`=spawn new tmux session + agent (dir picker → agent picker, window named `agent-<type>` or `main`) · `ctrl-x`=delete session (two-step, second press within 2s) · `ctrl-r`=refresh. Dir picker scans roots from `$DOT_PROJECT_ROOTS` (default: `~/GitHub ~/Workspace`) | `zsh/.zshrc.local:1538` |
| `tda` | `tda` | Full agent dashboard with live pane preview | `zsh/.zshrc.local:1584` |
| `tma` | `tma` | Agent monitor: auto-refresh 5s, `alt-s` send, `ctrl-x` stop, `alt-k` kill | `zsh/.zshrc.local:1625` |
| `tat` | `tat <description>` | Set task description on current pane's agent | `zsh/.zshrc.local:708` |

## AI agent — CLI continue variants

| Name | Command | Behavior | Definition |
|------|---------|----------|------------|
| `aac` | `aac [args]` | `claude -c` — continue most recent Claude session | `zsh/.zshrc.local:642` |
| `aoc` | `aoc [args]` | Codex continue (resume last session) | `zsh/.zshrc.local:643` |
| `agc` | `agc [args]` | Gemini continue | `zsh/.zshrc.local:650` |

> Non-continue (fresh) agent launches happen via tmux bindings `prefix+A/O/G`, not via standalone shell functions.

## AI agent — Claude behavior modes

| Name | Command | Behavior | Definition |
|------|---------|----------|------------|
| `cc-dev` | `cc-dev [args]` | Launch Claude appending the **dev** behavior context; if the context file is missing, launches plain with a hint | `zsh/.zshrc.local:1700` |
| `cc-research` | `cc-research [args]` | Same, appending the **research** context | `zsh/.zshrc.local:1701` |
| `cc-review` | `cc-review [args]` | Same, appending the **review** context | `zsh/.zshrc.local:1702` |

> Behavior contexts live in `~/.claude/contexts/<mode>.md` (not tracked in this repo; `cc-*` degrade gracefully if absent — append is skipped and a hint is shown). Shared helper `_dot_cc_ctx` at `zsh/.zshrc.local:1691`.

## Tmux key bindings (after `prefix` = `C-a`)

| Keys | Behavior | Definition |
|------|----------|------------|
| `prefix A` | Launch new Claude session in dedicated tmux window | `tmux/.tmux.conf.local:453` |
| `prefix O` | Launch new Codex session in dedicated tmux window | `tmux/.tmux.conf.local:457` |
| `prefix G` | Launch new Gemini session in dedicated tmux window | `tmux/.tmux.conf.local:461` |
| `prefix a` | Quick-ask Claude popup (one-shot Q&A) | `tmux/.tmux.conf.local:454` |
| `prefix o` | Quick-ask Codex popup | `tmux/.tmux.conf.local:458` |
| `prefix g` | Quick-ask Gemini popup | `tmux/.tmux.conf.local:462` |
| `prefix R` → `A/O/G` | Resume most recent Claude/Codex/Gemini (continue variants) | `tmux/.tmux.conf.local:470-474` |
| `prefix T` | Agent workspace popup (`tsa`) | `tmux/.tmux.conf.local:477` |
| `prefix D` | Full dashboard popup (`tda`) | `tmux/.tmux.conf.local:480` |
| `prefix K` | Set task description (command-prompt) | `tmux/.tmux.conf.local:483` |
| `prefix L` | Open lazygit in new window | `tmux/.tmux.conf.local:465` |
| `prefix l` | Lazygit popup | `tmux/.tmux.conf.local:466` |
| `prefix E` | Open scrollback in Neovim (read-only) | `tmux/.tmux.conf.local:486` |

## Git worktree (`wt*` family)

| Name | Command | Behavior | Definition |
|------|---------|----------|------------|
| `wtl` | `wtl` | List worktrees (alias of `git worktree list`) | `zsh/.zshrc.local:450` |
| `wta` | `wta <branch>` | Add worktree at sibling `<repo>-worktrees/<branch>` | `zsh/.zshrc.local:454` |
| `wtab` | `wtab` | Add worktree from fzf branch picker | `zsh/.zshrc.local:465` |
| `wtr` | `wtr [name]` | Remove worktree (fzf if no arg) | `zsh/.zshrc.local:514` |
| `wtp` | `wtp` | Prune empty worktree directories | `zsh/.zshrc.local:534` |
| `wtg` | `wtg [name]` | `cd` to worktree (fzf if no arg) | `zsh/.zshrc.local:557` |
| `wtb` | `wtb` | `cd` back to base / main repository | `zsh/.zshrc.local:577` |
| `wtm` | `wtm [name]` | Merge worktree branch back into base | `zsh/.zshrc.local:583` |
| `wtc` | `wtc <branch>` | Combo: add worktree + env init + launch AI agent | `zsh/.zshrc.local:620` |

## Brew (`b*` family)

| Name | Command | Behavior | Definition |
|------|---------|----------|------------|
| `bip` | `bip` | Interactive brew install (search + fzf preview) | `zsh/.zshrc.local:58` |
| `bup` | `bup` | Interactive brew upgrade picker | `zsh/.zshrc.local:74` |
| `bcp` | `bcp` | Interactive brew uninstall picker | `zsh/.zshrc.local:90` |
| `bci` | `bci` | Cask install with preview | `zsh/.zshrc.local:107` |
| `bcui` | `bcui` | Cask uninstall with preview | `zsh/.zshrc.local:131` |

## Git (`g*` family)

| Name | Command | Behavior | Definition |
|------|---------|----------|------------|
| `gla` | `gla` | Interactive git log via fzf | `zsh/.zshrc.local:248` |
| `gcob` | `gcob` | Checkout local branch via picker | `zsh/.zshrc.local:336` |
| `gcorb` | `gcorb` | Checkout remote branch via picker | `zsh/.zshrc.local:356` |
| `gdb` | `gdb` | Delete branch (safe) via picker | `zsh/.zshrc.local:291` |
| `gdfb` | `gdfb` | Force-delete branch via picker | `zsh/.zshrc.local:313` |

## File / system utilities

| Name | Command | Behavior | Definition |
|------|---------|----------|------------|
| `fcd` | `fcd` | fzf-pick a subdirectory and `cd` into it | `zsh/.zshrc.local:154` |
| `fcda` | `fcda` | Like `fcd` but includes hidden directories | `zsh/.zshrc.local:176` |
| `rmtrash` | `rmtrash <path>` | Move file to macOS Trash instead of `rm` | `zsh/.zshrc.local:199` |
| `untrash` | `untrash <name>` | Restore file from Trash | `zsh/.zshrc.local:203` |
| `lg` | `lg` | Launch lazygit | `zsh/.zshrc.local:658` |

## Static aliases

| Name | Maps to | Definition |
|------|---------|------------|
| `vim` / `vi` / `mvim` | `nvim` | `zsh/.zshrc.local:21-23` |
| `rm` | `rm -i` with warning prefix | `zsh/.zshrc.local:25` |
| `claude` | `command claude --allow-dangerously-skip-permissions` — makes bypass mode selectable via Shift+Tab (still starts in `default`). Use `command claude` for vanilla | `zsh/.zshrc.local:1685` |

## Configuration variables

| Name | Default | Behavior | Definition |
|------|---------|----------|------------|
| `DOT_PROJECT_ROOTS` | `($HOME/GitHub $HOME/Workspace)` | Root directories scanned by the `tsa` ctrl-n new-session dir picker. Override in `~/.zsh-machine.sh`. Non-existent roots are filtered; if none exist, falls back to `$HOME` | `zsh/.zshrc.local:18` |
| `DOT_BRANCH_PREFIXES` | `(feature/ bugfix/ hotfix/ fix/ chore/ release/ refactor/)` | Branch-name prefixes stripped when deriving the agent task label | `zsh/.zshrc.local:15` |
| `DOT_TSA_PENDING_FILE` | `$TMPDIR/tsa-delete-pending` | Path of the `tsa` ctrl-x two-step-delete state file | `zsh/.zshrc.local:11` |
| `DOT_TSA_CONFIRM_SECS` | `2` | Seconds within which a second `ctrl-x` confirms the delete | `zsh/.zshrc.local:12` |

---

## Drift notes

- Root `CLAUDE.md:113` previously listed `aa` / `ao` / `ag` as Claude/Codex/Gemini
  launchers. **Not implemented** — only the continue variants (`aac` / `aoc` / `agc`)
  exist. Fresh launches happen through tmux bindings `prefix+A/O/G`. Update root
  CLAUDE.md when you next touch that section.
