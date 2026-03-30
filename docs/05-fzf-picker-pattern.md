# FZF Picker Pattern

All interactive pickers share a consistent protocol: tab-delimited rows,
unified UI wrapper, and machine-readable key extraction.

## Why

The repo has 20+ fzf-based pickers (git branches, tmux sessions, brew packages,
worktrees, agents). Without a convention, each would have its own flag style,
output parsing, and error handling. The pattern ensures:

- **Consistent look**: every picker has the same height, border, and layout
- **Reliable parsing**: machine-readable keys never leak into display
- **Composability**: new pickers follow the same template in ~20 lines

## How It Works

### The Protocol

```
Data Source           Row Builder                FZF UI                Action
───────────          ───────────               ────────              ────────

git for-each-ref ──▶ dot_git_local_       ──▶ dot_fzf_ui()     ──▶ cut -f1
tmux list-panes      _branch_rows()           --delimiter=$'\t'      extracts
brew list        ──▶ dot_wt_rows()            --with-nth=2           machine-
git worktree list    dot_agent_pane_           (shows col 2+)         readable
                     _pretty_rows()                                    key
                                                                        │
                   Tab-delimited row:                                    ▼
                   KEY \t col1 \t col2 \t ...                      git checkout
                   ▲                                                tmux switch
                   │                                                brew install
                   hidden from user
                   (--with-nth=2)
```

### Core Helpers

**`dot_fzf_ui()`** — Unified fzf wrapper:

```bash
dot_fzf_ui() {
  fzf --height=55% --reverse --border --info=inline-right --highlight-line "$@"
}
```

Every picker calls `dot_fzf_ui` instead of `fzf` directly. This guarantees the
same layout across all pickers while allowing per-picker overrides via
additional arguments.

**`dot_require_fzf()`** — Guard function:

```bash
dot_require_fzf() {
  if ! command -v fzf >/dev/null 2>&1; then
    echo "fzf not found in PATH"
    return 1
  fi
}
```

Called at the top of every picker function to fail fast with a clear message.

### Tab-Delimited Row Convention

Row builder functions produce lines where:
- **Column 1**: machine-readable key (branch name, pane target, package name)
- **Columns 2+**: human-readable display (formatted, padded, colored)
- **Separator**: literal tab character (`$'\t'`)

```
main\t * main                    origin/main              2 hours ago
feat\t   feature-auth            origin/feature-auth      3 days ago
 ▲        ▲
 │        └── displayed to user (--with-nth=2)
 └── extracted after selection (cut -f1)
```

### Anatomy of a Picker Function

Every picker follows this template:

```bash
gcob() {                                        # 1. Function name
  dot_require_fzf || return 1                   # 2. Guard

  local rows branch
  rows="$(dot_git_local_branch_rows)"           # 3. Build rows
  [[ -z "$rows" ]] && return                    # 4. Empty check

  branch="$(                                    # 5. FZF selection
    printf '%s\n' "$rows" |
      dot_fzf_ui \
        --prompt='git checkout> ' \             #    Custom prompt
        --delimiter=$'\t' --with-nth=2 \        #    Hide col 1
        --header='  branch       upstream   last commit' |
      cut -f1                                   # 6. Extract key
  )"
  [[ -z "$branch" ]] && return                  # 7. Escape check

  git checkout "$branch"                        # 8. Action
}
```

### Row Builder Examples

**Git branches** (`dot_git_local_branch_rows`):
```
main    * main                    origin/main              2h ago
feat      feature-auth            -                        3d ago
```

**Worktrees** (`dot_wt_pretty_rows`):
```
/path/main     *  main            main                 /Users/.../repo
/path/feat        feature-x       feature/feature-x    /Users/.../repo-worktrees/feat
```

**Tmux sessions** (`dot_tmux_session_pretty_rows`):
```
dev     ●  dev          3 windows    attached
work    ○  work         5 windows
```

**Agent panes** (`dot_agent_pane_pretty_rows`):
```
dev:agent-claude.0   claude   dev    my-project   ● active   12s   ~/GitHub/proj
work:agent-codex.1   codex    work   api-server   ○ idle     5m    ~/work/api
```

### Naming Convention

| Prefix | Purpose | Example |
|--------|---------|---------|
| `dot_*_rows()` | Raw row builder | `dot_git_local_branch_rows()` |
| `dot_*_pretty_rows()` | Colored/formatted rows | `dot_agent_pane_pretty_rows()` |
| `dot_fzf_ui()` | FZF wrapper | — |
| `dot_require_fzf()` | FZF guard | — |

### Complete Picker Inventory

```
Category    Picker     Action                  Row Builder
────────    ──────     ──────                  ───────────
Git         gla        Interactive log         (git log --oneline)
            gcob       Checkout local branch   dot_git_local_branch_rows
            gcorb      Checkout remote branch  dot_git_remote_branch_rows
            gdb/gdfb   Delete branch           dot_git_local_branch_rows

Worktree    wtab       Add from branch         dot_git_local_branch_rows +
                                               dot_git_remote_branch_rows
            wtr        Remove worktree         dot_wt_pretty_rows
            wtg        Go to worktree          dot_wt_pretty_rows
            wtm        Merge worktree          dot_wt_pretty_rows

Tmux        ts         Switch session          dot_tmux_session_pretty_rows
            tk         Kill session            dot_tmux_session_pretty_rows
            tsw        Switch window           dot_tmux_window_pretty_rows
            tsp        Switch pane             dot_tmux_pane_pretty_rows
            tsa        Agent dashboard         dot_agent_pane_pretty_rows

Brew        bip        Install formula         brew formulae
            bup        Upgrade formula         brew outdated
            bcp        Uninstall formula       brew leaves
            bci        Install cask            brew search --casks
            bcui       Uninstall cask          brew list --cask

Dir         fcd        cd (one level)          ls
            fcda       cd (recursive + hidden) fd --type d

System      untrash    Restore from trash      (custom trash listing)
```

## Key Files

| File | Role |
|------|------|
| `zsh/.zshrc.local` (lines 34-36) | `dot_fzf_ui()` definition |
| `zsh/.zshrc.local` (lines 818-822) | `dot_require_fzf()` definition |
| `zsh/.zshrc.local` | All picker functions and row builders |
| `zsh/.zshrc` (lines 309-368) | FZF base configuration |

## See Also

- [06-tmux-agent-orchestration.md](06-tmux-agent-orchestration.md) — agent pickers use this pattern
- [08-agent-dashboard.md](08-agent-dashboard.md) — the most complex picker (tsa)
- [11-worktree-workflow.md](11-worktree-workflow.md) — worktree pickers
