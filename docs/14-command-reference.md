# Command Reference

Flat inventory of every user-facing function, alias, and tmux binding defined
in this repo. For *why* a command exists or *how* the underlying pattern works,
see the technique docs (`01-*.md` through `13-*.md`).

**Source locations:**
- Shell functions / aliases: `zsh/.zshrc.local`
- Tmux key bindings: `tmux/.tmux.conf.local`
- Canonical name list (OMZ alias shadow guard): `zsh/.zshrc.local:647`

> The **Definition** column gives `file:line` for fast jumping. Keep it accurate.

---

## Tmux — session / window / pane

| Name | Command | Behavior | Definition |
|------|---------|----------|------------|
| `tl` | `tl` | List all tmux sessions in a table (marker, state, name, clients, wins) | `zsh/.zshrc.local:1033` |
| `tx` | `tx [name]` | Create new session or switch to existing. Default name = `basename $PWD` | `zsh/.zshrc.local:1044` |
| `ts` | `ts` | fzf picker for switching to another session | `zsh/.zshrc.local:1058` |
| `tk` | `tk [name]` | Kill session (fzf picker if no arg) | `zsh/.zshrc.local:1083` |
| `tsw` | `tsw` | fzf picker for switching window across all sessions | `zsh/.zshrc.local:1105` |
| `tsp` | `tsp` | fzf picker for switching pane across all sessions | `zsh/.zshrc.local:1329` |
| `tw` | `tw [name]` | Expand current session into multi-window workspace: editor / agent / test / logs | `zsh/.zshrc.local:1241` |

## Tmux — AI agent management

| Name | Command | Behavior | Definition |
|------|---------|----------|------------|
| `tla` | `tla` | List all running AI agents (table) | `zsh/.zshrc.local:1536` |
| `tsa` | `tsa` | Agent workspace popup: list active agents + `ctrl-n` to spawn new tmux session + agent (dir picker → agent picker) | `zsh/.zshrc.local:1425` |
| `tda` | `tda` | Full agent dashboard with live pane preview | `zsh/.zshrc.local:1463` |
| `tma` | `tma` | Agent monitor: auto-refresh 5s, `alt-s` send, `ctrl-x` stop, `alt-k` kill | `zsh/.zshrc.local:1504` |
| `tat` | `tat <description>` | Set task description on current pane's agent | `zsh/.zshrc.local:679` |

## AI agent — CLI continue variants

| Name | Command | Behavior | Definition |
|------|---------|----------|------------|
| `aac` | `aac [args]` | `claude -c` — continue most recent Claude session | `zsh/.zshrc.local:623` |
| `aoc` | `aoc [args]` | Codex continue (resume last session) | `zsh/.zshrc.local:624` |
| `agc` | `agc [args]` | Gemini continue | `zsh/.zshrc.local:631` |

> Non-continue (fresh) agent launches happen via tmux bindings `prefix+A/O/G`, not via standalone shell functions.

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
| `wtl` | `wtl` | List worktrees (alias of `git worktree list`) | `zsh/.zshrc.local:431` |
| `wta` | `wta <branch>` | Add worktree at sibling `<repo>-worktrees/<branch>` | `zsh/.zshrc.local:435` |
| `wtab` | `wtab` | Add worktree from fzf branch picker | `zsh/.zshrc.local:446` |
| `wtr` | `wtr [name]` | Remove worktree (fzf if no arg) | `zsh/.zshrc.local:495` |
| `wtp` | `wtp` | Prune empty worktree directories | `zsh/.zshrc.local:515` |
| `wtg` | `wtg [name]` | `cd` to worktree (fzf if no arg) | `zsh/.zshrc.local:538` |
| `wtb` | `wtb` | `cd` back to base / main repository | `zsh/.zshrc.local:558` |
| `wtm` | `wtm [name]` | Merge worktree branch back into base | `zsh/.zshrc.local:564` |
| `wtc` | `wtc <branch>` | Combo: add worktree + env init + launch AI agent | `zsh/.zshrc.local:601` |

## Brew (`b*` family)

| Name | Command | Behavior | Definition |
|------|---------|----------|------------|
| `bip` | `bip` | Interactive brew install (search + fzf preview) | `zsh/.zshrc.local:39` |
| `bup` | `bup` | Interactive brew upgrade picker | `zsh/.zshrc.local:55` |
| `bcp` | `bcp` | Interactive brew uninstall picker | `zsh/.zshrc.local:71` |
| `bci` | `bci` | Cask install with preview | `zsh/.zshrc.local:88` |
| `bcui` | `bcui` | Cask uninstall with preview | `zsh/.zshrc.local:112` |

## Git (`g*` family)

| Name | Command | Behavior | Definition |
|------|---------|----------|------------|
| `gla` | `gla` | Interactive git log via fzf | `zsh/.zshrc.local:229` |
| `gcob` | `gcob` | Checkout local branch via picker | `zsh/.zshrc.local:317` |
| `gcorb` | `gcorb` | Checkout remote branch via picker | `zsh/.zshrc.local:337` |
| `gdb` | `gdb` | Delete branch (safe) via picker | `zsh/.zshrc.local:272` |
| `gdfb` | `gdfb` | Force-delete branch via picker | `zsh/.zshrc.local:294` |

## File / system utilities

| Name | Command | Behavior | Definition |
|------|---------|----------|------------|
| `fcd` | `fcd` | fzf-pick a subdirectory and `cd` into it | `zsh/.zshrc.local:135` |
| `fcda` | `fcda` | Like `fcd` but includes hidden directories | `zsh/.zshrc.local:157` |
| `rmtrash` | `rmtrash <path>` | Move file to macOS Trash instead of `rm` | `zsh/.zshrc.local:180` |
| `untrash` | `untrash <name>` | Restore file from Trash | `zsh/.zshrc.local:184` |
| `lg` | `lg` | Launch lazygit | `zsh/.zshrc.local:639` |

## Static aliases

| Name | Maps to | Definition |
|------|---------|------------|
| `vim` / `vi` / `mvim` | `nvim` | `zsh/.zshrc.local:2-4` |
| `rm` | `rm -i` with warning prefix | `zsh/.zshrc.local:6` |

---

## Drift notes

- Root `CLAUDE.md:113` previously listed `aa` / `ao` / `ag` as Claude/Codex/Gemini
  launchers. **Not implemented** — only the continue variants (`aac` / `aoc` / `agc`)
  exist. Fresh launches happen through tmux bindings `prefix+A/O/G`. Update root
  CLAUDE.md when you next touch that section.
