# Agent Status Segment

A tmux-powerline segment that shows the count of running AI agents in the
status bar, automatically hiding when no agents are active.

## Why

The agent dashboard (doc 08) requires a keypress to open. The status segment
provides a passive, always-visible indicator: a glance at the status bar tells
you if agents are running and which types.

## How It Works

### Status Bar Anatomy

```
┌──────────────────────────────────────────────────────────────────────────┐
│                           tmux status bar                                │
│                                                                          │
│  ◀── LEFT ──────────────────────────────── RIGHT ──▶                    │
│                                                                          │
│  ┌────────┬──────────┐              ┌───────────┬────────┬──────────┐   │
│  │session │ uptime   │  (windows)   │agent_status│  date  │   time  │   │
│  │ "dev"  │ "3d 2h"  │              │  "C:2 O"  │ Mar 30 │  14:32  │   │
│  └────────┴──────────┘              └───────────┴────────┴──────────┘   │
│                                      ▲                                   │
│                                      │                                   │
│                            Hidden when no agents running                 │
└──────────────────────────────────────────────────────────────────────────┘
```

### Segment Logic

The segment queries all tmux panes and counts agent processes:

```bash
# config/tmux-powerline/segments/agent_status.sh

tmux list-panes -a -F '#{pane_current_command}' | awk '
  /^claude$/ { c++ }
  /^codex$/  { o++ }
  /^gemini$/ { g++ }
  END {
    parts=""
    if (c>0) parts = parts (parts=="" ? "" : " ") "C" (c>1 ? ":" c : "")
    if (o>0) parts = parts (parts=="" ? "" : " ") "O" (o>1 ? ":" o : "")
    if (g>0) parts = parts (parts=="" ? "" : " ") "G" (g>1 ? ":" g : "")
    if (parts != "") print parts
  }
'
```

### Output Examples

```
No agents:    (segment hidden — prints nothing)
1 Claude:     C
2 Claudes:    C:2
1 of each:    C O G
Mixed:        C:2 O G:3
```

### Conditional Visibility

When the awk script produces no output (no agents running), tmux-powerline
automatically hides the segment. No blank space appears in the status bar.

### Theme Integration

Configured in the Tokyo Night Storm minimal theme:

```bash
# config/tmux-powerline/themes/tokyonight_storm_minimal.sh

TMUX_POWERLINE_RIGHT_STATUS_SEGMENTS=(
  "agent_status #9ece6a #1f2335"    # Green text, dark background
  "date #c0caf5 #1f2335"
  "time #c0caf5 #1f2335"
)
```

The green color (`#9ece6a`) makes the agent indicator pop against the dark
Tokyo Night background (`#1f2335`).

### Refresh Interval

The powerline refreshes every 5 seconds:

```bash
# config/tmux-powerline/config.sh
TMUX_POWERLINE_STATUS_INTERVAL="5"
```

This means agent count updates within 5 seconds of an agent starting or
stopping.

## Key Files

| File | Role |
|------|------|
| `config/tmux-powerline/segments/agent_status.sh` | Segment implementation |
| `config/tmux-powerline/themes/tokyonight_storm_minimal.sh` | Theme config |
| `config/tmux-powerline/config.sh` | Refresh interval |

## See Also

- [08-agent-dashboard.md](08-agent-dashboard.md) — interactive agent monitoring
- [06-tmux-agent-orchestration.md](06-tmux-agent-orchestration.md) — how agents are launched
