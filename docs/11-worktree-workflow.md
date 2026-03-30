# Worktree Workflow

Git worktrees in a sibling directory convention, with fzf-based lifecycle
functions for adding, navigating, merging, and cleaning up.

## Why

Feature branches require context switching — stashing changes, checking out,
rebuilding. Git worktrees let you have multiple branches checked out
simultaneously in separate directories. Combined with tmux, you can have each
feature in its own window with its own agent.

The sibling directory convention keeps worktrees organized and predictable:

```
~/GitHub/
├── my-project/                    ◀── main worktree (base repo)
└── my-project-worktrees/          ◀── sibling directory
    ├── feature-auth/              ◀── worktree for feature/feature-auth
    ├── fix-login/                 ◀── worktree for feature/fix-login
    └── refactor-api/              ◀── worktree for feature/refactor-api
```

## How It Works

### Directory Layout

```
dot_wt_sibling_dir() computes the worktree root:

  git rev-parse --show-toplevel
       │
       ▼
  ~/GitHub/my-project
       │
       ├── basename ──▶ "my-project"
       └── dirname  ──▶ "~/GitHub"
       │
       ▼
  ~/GitHub/my-project-worktrees/     ◀── append "-worktrees"
```

### Function Lifecycle

```
┌────────────────────────────────────────────────────────────────────┐
│                        Worktree Lifecycle                          │
│                                                                    │
│  CREATE                                                            │
│  ┌──────┐    ┌──────┐                                             │
│  │ wta  │    │ wtab │                                             │
│  │ name │    │ pick │                                             │
│  └──┬───┘    └──┬───┘                                             │
│     │           │                                                  │
│     └─────┬─────┘                                                  │
│           ▼                                                        │
│     git worktree add                                               │
│     <sibling-dir>/<name>                                           │
│     -b feature/<name>                                              │
│           │                                                        │
│  ┌────────┼─────────────────────────────────┐                     │
│  │ NAVIGATE                                  │                     │
│  │  ┌──────┐   ┌──────┐   ┌──────┐         │                     │
│  │  │ wtg  │   │ wtb  │   │ wtl  │         │                     │
│  │  │ pick │   │ base │   │ list │         │                     │
│  │  └──────┘   └──────┘   └──────┘         │                     │
│  └──────────────────────────────────────────┘                     │
│           │                                                        │
│  ┌────────┼─────────────────────────────────┐                     │
│  │ INTEGRATE                                 │                     │
│  │  ┌──────┐                                 │                     │
│  │  │ wtm  │  pick worktree → merge to main  │                     │
│  │  │merge │  → optionally remove worktree    │                     │
│  │  └──────┘                                 │                     │
│  └──────────────────────────────────────────┘                     │
│           │                                                        │
│  ┌────────┼─────────────────────────────────┐                     │
│  │ CLEANUP                                   │                     │
│  │  ┌──────┐   ┌──────┐                     │                     │
│  │  │ wtr  │   │ wtp  │                     │                     │
│  │  │remove│   │prune │                     │                     │
│  │  └──────┘   └──────┘                     │                     │
│  └──────────────────────────────────────────┘                     │
└────────────────────────────────────────────────────────────────────┘
```

### Function Reference

**Creating**

| Function | Usage | What It Does |
|----------|-------|--------------|
| `wta <name>` | `wta auth-refactor` | Creates worktree + branch `feature/<name>`, cd into it |
| `wtab` | (interactive) | FZF picker of local+remote branches → create worktree from selection |
| `wtc <name> [agent]` | `wtc auth claude` | `wta` + auto-detect env + install deps + launch agent |

**Navigating**

| Function | Usage | What It Does |
|----------|-------|--------------|
| `wtg` | (interactive) | FZF picker → cd to selected worktree |
| `wtb` | (direct) | cd to base repo (main worktree) |
| `wtl` | (direct) | List all worktrees (`git worktree list`) |

**Integrating**

| Function | Usage | What It Does |
|----------|-------|--------------|
| `wtm` | (interactive) | Pick worktree → merge its branch to main → optionally remove |

**Cleaning Up**

| Function | Usage | What It Does |
|----------|-------|--------------|
| `wtr` | (interactive) | Pick worktree → `git worktree remove` |
| `wtp` | (direct) | Remove `<repo>-worktrees/` dir if empty |

### `wtc`: Full Setup Function

The most powerful function — creates a worktree, initializes the dev
environment, and launches an AI agent:

```bash
wtc() {
  local name="$1"
  local agent="${2:-claude}"

  wta "$name" || return 1

  # Auto-detect package manager and install
  if [[ -f "package.json" ]]; then
    if [[ -f "pnpm-lock.yaml" ]]; then pnpm install
    elif [[ -f "yarn.lock" ]]; then yarn install
    else npm install
    fi
  fi

  # Python environment setup
  if [[ -f "pyproject.toml" || -f "requirements.txt" ]]; then
    if command -v uv &>/dev/null; then uv sync
    else python -m venv .venv && source .venv/bin/activate && pip install -r requirements.txt
    fi
  fi

  $agent   # Launch specified agent
}
```

### FZF Integration

Worktree pickers use the standard picker pattern (see doc 05):

```bash
dot_wt_pretty_rows() {
  # Tab-delimited: path \t marker \t name \t branch \t full_path
  git worktree list --porcelain | awk '...'
}

wtg() {
  dot_require_fzf || return 1
  local rows target
  rows="$(dot_wt_pretty_rows)"
  [[ -z "$rows" ]] && return

  target="$(printf '%s\n' "$rows" |
    dot_fzf_ui --prompt='worktree> ' --delimiter=$'\t' --with-nth=2 |
    cut -f1)"
  [[ -z "$target" ]] && return

  cd "$target"
}
```

## Key Files

| File | Role |
|------|------|
| `zsh/.zshrc.local` | All `wt*` functions and `dot_wt_*` helpers |

## See Also

- [05-fzf-picker-pattern.md](05-fzf-picker-pattern.md) — underlying picker conventions
- [06-tmux-agent-orchestration.md](06-tmux-agent-orchestration.md) — agents in worktree windows
