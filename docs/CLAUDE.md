# docs/ Maintenance Contract

This folder houses two kinds of documentation:

1. **Technique docs** (`01-*.md` through `13-*.md`) — architectural patterns and
   "why/how" explanations. Each is reasonably stable; updated only when the
   underlying pattern changes.
2. **Command reference** (`14-command-reference.md`) — flat inventory of every
   user-facing function, alias, and tmux binding. **High churn** — must be
   updated alongside any change to `zsh/.zshrc.local` or `tmux/.tmux.conf.local`.

## When to update

| You changed... | Update... |
|----------------|-----------|
| Added a new function/alias in `zsh/.zshrc.local` | Add a row to `14-command-reference.md` under the matching category |
| Removed a function/alias | Remove its row from `14-command-reference.md` |
| Renamed a function | Update **Name** + **Definition** columns |
| Moved code (line number shift) | Update **Definition** column |
| Added/changed a tmux `bind-key` in `tmux/.tmux.conf.local` | Add/update row under "Tmux key bindings" |
| Introduced a new architectural pattern | Create new `15-*.md` technique doc + add to `README.md` index |
| Substantially changed an existing technique | Update the relevant `0X-*.md` |
| Added/removed a top-level `docs/` file | Update `README.md` index |

## Format conventions

### Command reference rows

```markdown
| Name | Command | Behavior | Definition |
|------|---------|----------|------------|
| `tx` | `tx [name]` | Create new session or switch to existing | `zsh/.zshrc.local:1088` |
```

- **Name**: function/alias/binding identifier in backticks, no leading `$`
- **Command**: how the user types it, with `<required>` and `[optional]` arg placeholders
- **Behavior**: one imperative sentence — what it does, not how
- **Definition**: `file:line` (file path relative to repo root). **Must always be accurate** — this is the breadcrumb back to source.

### Technique docs

- Numbered `0X-name.md` (kebab-case after the number)
- One-line summary at top, then "Why" + "How" sections
- ASCII diagrams when structure helps
- See existing `01-stow-deployment.md` for template

## Sync checklist when modifying `zsh/.zshrc.local`

1. If you added a function whose name might clash with an OMZ plugin alias,
   add it to the `unalias` line at `zsh/.zshrc.local:666`
2. Run `grep -n "^function_name()" zsh/.zshrc.local` to confirm the new line
3. Update **Definition** column in `14-command-reference.md`
4. If removed, also remove from the `unalias` line

## Machine-specific values: keep them OUT of the repo

`zsh/.zshrc.local` is **tracked** in this repo, so anything committed there is
shared across all your machines (and visible on a public remote). Use the
escape hatch instead for machine-specific values:

- **File**: `~/.zsh-machine.sh` (lives in `$HOME`, never in repo)
- **Sourced from**: top of `zsh/.zshrc.local` (look for `~/.zsh-machine.sh`)
- **Use for**: project root paths, work-specific config, secrets, anything
  that differs across machines or you don't want to commit

Example `~/.zsh-machine.sh`:

```zsh
DOT_PROJECT_ROOTS=("$HOME/GitHub" "$HOME/Workspace/<work-area>")
export WORK_API_TOKEN="..."
```

If you find yourself about to commit a machine-specific path or value into
`zsh/.zshrc.local`, stop — extract it to `~/.zsh-machine.sh` instead, and
keep only the **default** (or a sentinel like `[[ -z $VAR ]] && VAR=...`)
in `.zshrc.local`.

## Sync checklist when modifying `tmux/.tmux.conf.local`

1. Reload: `tmux source-file ~/.tmux.conf` and verify the binding works
2. Update line number in `14-command-reference.md` under "Tmux key bindings"
3. If the popup version (`bind-key <lowercase>`) doesn't yet pass
   `-e DOT_POPUP=1`, add it so the popup skips `load-nvmrc` overhead
   (see `zsh/.zshrc.local:415`)

## Drift detection (run when in doubt)

```bash
# Functions in zshrc.local that aren't in the doc
grep -E "^[a-z][a-z_0-9]*\(\)" zsh/.zshrc.local | sed 's/().*//' | sort -u > /tmp/funcs
grep -oE '\| `[a-z][a-z_0-9]*` \|' docs/14-command-reference.md | tr -d '|` ' | sort -u > /tmp/docs
diff /tmp/funcs /tmp/docs
```

This shows asymmetry: functions defined but not documented, or documented but
no longer defined. Run after any non-trivial refactor of `.zshrc.local`.

## Reading order for new visitors

1. `README.md` — index + architecture overview
2. `14-command-reference.md` — what's actually available to type
3. `01-stow-deployment.md` + `02-shell-environment.md` — foundation
4. Pick from `06-09` for agent system, `11` for worktree
