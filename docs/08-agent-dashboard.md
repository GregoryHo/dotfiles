# Agent Dashboard

A live-updating fzf popup (`tsa` / `prefix+T`) that shows all running AI agents
across all tmux sessions, with pane preview, status detection, and interactive
controls.

## Why

When running multiple agents across multiple projects, you lose track of what's
running where. The dashboard provides a single view of all active agents with
their status, project, idle time, and live output — plus controls to switch to,
stop, or send commands to any agent.

## How It Works

### Detection Pipeline

```
tmux list-panes -a
        │
        ▼
┌───────────────────────────────┐
│  Filter: window name matches  │
│  "agent-claude"               │
│  "agent-codex"                │
│  "agent-gemini"               │
│                               │
│  Fallback: pane command is    │
│  "claude" / "codex" / "gemini"│
└───────────┬───────────────────┘
            │
            ▼
┌───────────────────────────────┐
│  For each matching pane:      │
│                               │
│  target  = session:window.pane│
│  agent   = claude/codex/gemini│
│  session = tmux session name  │
│  project = basename of cwd    │
│  status  = active/idle/exited │
│  idle    = time since activity│
│  cwd     = working directory  │
└───────────┬───────────────────┘
            │
            ▼
┌───────────────────────────────┐
│  Color-code and format:       │
│                               │
│  Agent colors:                │
│    claude  = magenta          │
│    codex   = green            │
│    gemini  = blue             │
│                               │
│  Status indicators:           │
│    ● active  (green)          │
│    ◉ busy    (yellow)         │
│    ○ idle    (gray)           │
│    ✕ exited  (red)            │
└───────────────────────────────┘
```

### Status State Machine

```
                    ┌──────────┐
         start ───▶│ ● active │◀──── pane activity detected
                    └────┬─────┘       within threshold
                         │
                    no activity
                    for 30s+
                         │
                    ┌────▼─────┐
                    │ ○ idle   │◀──── no recent pane activity
                    └────┬─────┘
                         │
                    process exits
                         │
                    ┌────▼─────┐
                    │ ✕ exited │◀──── pane command changed or
                    └──────────┘       process no longer running
```

### Dashboard UI

```
┌──────────────────────────────────────────────────────────────────────┐
│  Agent Dashboard                                           ctrl-r ↻  │
│                                                                      │
│  ┌────────────────────────────────┬─────────────────────────────────┐│
│  │  Agent List                    │  Live Pane Preview              ││
│  │                                │                                 ││
│  │  claude  dev    my-proj  ● 12s │  $ claude                       ││
│  │  codex   work   api     ○ 5m  │  > I'll help you refactor...    ││
│  │  gemini  dev    ml-exp  ● 3s  │  > Here's my suggestion:        ││
│  │  claude  test   utils   ✕     │  > ...                          ││
│  │                                │                                 ││
│  └────────────────────────────────┴─────────────────────────────────┘│
│                                                                      │
│  enter=switch  ctrl-x=stop  alt-k=kill  alt-s=send cmd  ctrl-r=refresh│
└──────────────────────────────────────────────────────────────────────┘
```

### Interactive Controls

| Key | Action | Implementation |
|-----|--------|----------------|
| `Enter` | Switch to agent pane | `dot_tmux_goto_pane(target)` |
| `ctrl-r` | Refresh agent list | Reloads row builder |
| `ctrl-x` | Stop agent | Sends `C-c` to agent pane |
| `alt-k` | Kill pane | `tmux kill-pane -t {target}` |
| `alt-s` | Send command | Prompts for input, sends to agent pane |

### Auto-Refresh

A background process polls every 2 seconds, posting to fzf's HTTP endpoint:

```bash
(while true; do
  sleep 2
  curl -s -XPOST "localhost:$PORT" -d "reload(...)" >/dev/null 2>&1
done) &
```

This keeps the list and status indicators current without manual refresh.

### Live Preview

The preview window captures the agent's pane output with ANSI stripping:

```bash
tmux capture-pane -t "$target" -p -S -50 | sed 's/\x1b\[[0-9;]*m//g'
```

This shows the last 50 lines of the agent's terminal, auto-following new output.

### Pane Navigation Helper

`dot_tmux_goto_pane` handles the full coordinates (`session:window.pane`):

```bash
dot_tmux_goto_pane() {
  local target="$1"
  local session="${target%%:*}"

  if [[ "$(tmux display-message -p '#{session_name}')" != "$session" ]]; then
    tmux switch-client -t "$session"
  fi
  tmux select-window -t "$target"
  tmux select-pane -t "$target"
}
```

## Key Files

| File | Role |
|------|------|
| `zsh/.zshrc.local` (lines 879-960) | `dot_agent_pane_rows` + `dot_agent_pane_pretty_rows` |
| `zsh/.zshrc.local` (lines 1272-1310) | `tsa()` dashboard function |
| `zsh/.zshrc.local` (lines 1312-1324) | `tla()` text-only agent list |
| `zsh/.zshrc.local` (lines 1243-1254) | `dot_tmux_goto_pane()` helper |
| `tmux/.tmux.conf.local` | `prefix+T` binding |

## See Also

- [06-tmux-agent-orchestration.md](06-tmux-agent-orchestration.md) — how agents are launched
- [09-agent-status-segment.md](09-agent-status-segment.md) — always-visible agent count
- [05-fzf-picker-pattern.md](05-fzf-picker-pattern.md) — underlying picker conventions
