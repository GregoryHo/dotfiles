# Tmux Agent Orchestration

A hybrid keybinding system that launches AI agents (Claude, Codex, Gemini) in
two modes: full persistent windows for deep work, or ephemeral popups for quick
questions.

## Why

Three AI coding agents need to be accessible without leaving tmux. Different
situations need different interaction modes:

- **Deep work**: agent needs its own window, persistent history, and your full
  project context (code reviews, debugging sessions, multi-step tasks)
- **Quick questions**: ask something fast, get the answer, close the popup,
  stay in flow

A single keybinding scheme handles both modes for all three agents plus resume
functionality.

## How It Works

### The Hybrid Flow

```
                        ┌─── prefix + UPPERCASE ────┐
                        │   (A / O / G)             │
                        │                           ▼
                        │               ┌────────────────────────┐
                        │               │  New tmux window        │
                        │               │  name: agent-{type}     │
                        │               │  cwd: @project_path     │
                        │               │  Agent runs in fg       │
                        │               │  On exit → notify 🔔    │
                        │               └────────────────────────┘
     User at            │
     tmux ──────────────┤
                        │
                        │   ┌─── prefix + lowercase ────┐
                        │   │   (a / o / g)             │
                        │   │                           ▼
                        │   │               ┌────────────────────────┐
                        │   │               │  Popup (80% × 60%)     │
                        │   │               │  dot_quick_ask {type}   │
                        │   │               │  Ephemeral Q&A REPL    │
                        │   │               │  Background processing │
                        │   │               │  Auto-cleanup on exit  │
                        │   │               └────────────────────────┘
                        │   │
                        └───┤
                            │
                            ├─── prefix + R ────────────┐
                            │   then A / O / G          │
                            │                           ▼
                            │               ┌────────────────────────┐
                            │               │  Resume last session    │
                            │               │  Claude: -c flag        │
                            │               │  Codex: resume --last   │
                            │               │  Gemini: --resume       │
                            │               └────────────────────────┘
                            │
                            └─── prefix + T ────────────┐
                                                        ▼
                                            ┌────────────────────────┐
                                            │  Agent Dashboard        │
                                            │  fzf picker of all      │
                                            │  running agents         │
                                            │  (see doc 08)           │
                                            └────────────────────────┘
```

### Keybinding Matrix

| Binding | Agent | Mode | Persistence |
|---------|-------|------|-------------|
| `prefix+A` | Claude | Full window | Persistent until exit |
| `prefix+O` | Codex | Full window | Persistent until exit |
| `prefix+G` | Gemini | Full window | Persistent until exit |
| `prefix+a` | Claude | Quick-ask popup | Ephemeral |
| `prefix+o` | Codex | Quick-ask popup | Ephemeral |
| `prefix+g` | Gemini | Quick-ask popup | Ephemeral |
| `prefix+R` → `A/O/G` | Any | Resume modal | Continues last session |
| `prefix+T` | All | Dashboard popup | Read-only overview |
| `prefix+L` | Lazygit | Full window | Persistent until exit |
| `prefix+l` | Lazygit | Popup | Ephemeral |

### Full Window Launch (Uppercase)

```bash
bind-key A run-shell -b '
  p="#{?@project_path,#{@project_path},#{pane_current_path}}";
  tmux new-window -n agent-claude -c "$p";
  tmux set-option -w @project_path "$p";
  tmux send-keys "claude; dot_notify_agent claude \"$p\"" C-m'
```

**What this does**:
1. **Resolve project path**: tries `@project_path` window option first, falls
   back to current pane's working directory
2. **Create new window**: named `agent-claude`, working directory set to project
3. **Persist project path**: stores in window option for future agent launches
4. **Chain commands**: agent launch → notification on exit
5. **Run in background** (`-b`): doesn't block the current pane

### The `@project_path` Window Option

```
Problem:  Agent TUIs (Claude, Codex) change their own cwd internally.
          #{pane_current_path} becomes unreliable after launch.

Solution: Store the project path as a tmux window option BEFORE launch.
          Future agent spawns in the same window read this option.

    ┌─────────────────┐         ┌─────────────────┐
    │ Before launch:   │         │ After launch:    │
    │ cwd = ~/project  │         │ cwd = /tmp/xxx   │ ◀── agent changed it
    │ @project = nil   │         │ @project = ~/proj│ ◀── window option stable
    └─────────────────┘         └─────────────────┘
```

### Quick-Ask Popup (Lowercase)

```bash
bind-key a run-shell -b '
  p="#{?@project_path,#{@project_path},#{pane_current_path}}";
  tmux display-popup -E -w 80% -h 60% -d "$p" \
    "$SHELL -lic \"dot_quick_ask claude\"" || true'
```

Opens a popup window running the `dot_quick_ask` REPL (see
[07-quick-ask-repl.md](07-quick-ask-repl.md)). The `-E` flag closes the popup
when the process exits. `|| true` prevents error codes from propagating.

### Resume Mode (prefix+R)

```bash
bind-key R display-menu -T "continue>" \
  "A  Claude"  A "run-shell -b '...aac; dot_notify_agent claude...'" \
  "O  Codex"   O "run-shell -b '...aoc; dot_notify_agent codex...'" \
  "G  Gemini"  G "run-shell -b '...agc; dot_notify_agent gemini...'" \
  ""           "" "" \
  "Esc cancel" "" ""
```

Displays a modal menu. Each option calls the continue alias:

| Alias | Behavior |
|-------|----------|
| `aac` | `claude -c` (continue last conversation) |
| `aoc` | `codex resume --last` |
| `agc` | `gemini --resume latest` |

### Notification on Exit

Every agent launch chains `dot_notify_agent` after the agent command:

```bash
dot_notify_agent() {
  local agent="${1:-agent}" project="${2:-}"
  local name="${project##*/}"
  [[ -z "$name" ]] && name="$agent"
  osascript -e "display notification \"${agent} finished in ${name}\" \
    with title \"Agent Complete\" sound name \"Glass\"" 2>/dev/null
}
```

Sends a macOS notification with the "Glass" system sound when any agent exits.

### Shell Aliases

Continue aliases resume the most recent agent session:

```bash
aac() { claude -c "$@"; }                                    # Resume Claude
aoc() {                                                      # Resume Codex
  [[ "$#" -eq 0 ]] && codex resume --last || codex resume "$@"
}
agc() {                                                      # Resume Gemini
  [[ "$#" -eq 0 ]] && gemini --resume latest || gemini --resume "$@"
}
```

For new sessions, agents are launched directly by name (`claude`, `codex`,
`gemini`) — no wrapper aliases needed.

## Key Files

| File | Role |
|------|------|
| `tmux/.tmux.conf.local` (lines 444-466) | All agent keybindings |
| `zsh/.zshrc.local` (lines 625-656) | Shell aliases and dot_notify_agent |
| `zsh/.zshrc.local` (lines 658-817) | dot_quick_ask function |

## See Also

- [07-quick-ask-repl.md](07-quick-ask-repl.md) — the popup REPL architecture
- [08-agent-dashboard.md](08-agent-dashboard.md) — monitoring all agents
- [09-agent-status-segment.md](09-agent-status-segment.md) — status bar indicator
