# Quick-Ask REPL

An fzf-based Q&A loop where questions are sent to AI agents in the background,
with answers streaming into a live preview pane.

## Why

Sometimes you need a quick answer without committing to a full agent session.
The quick-ask REPL lets you type a question, immediately start typing the next
one while the first answer generates in the background, and copy results when
ready. It's the equivalent of having a chat sidebar, built entirely from fzf +
shell scripts.

## How It Works

### Architecture

```
┌──────────────────────────────────────────────────────────────┐
│  fzf (--listen 127.0.0.1:PORT --disabled)                    │
│                                                               │
│  ┌──────────────────────┬──────────────────────────────────┐ │
│  │  History List (30%)  │  Preview Window (70%)             │ │
│  │                      │                                   │ │
│  │  ✓  What is X?      │  X is a framework that...          │ │
│  │  ✓  How to do Y?    │                                   │ │
│  │  ⏳ Explain Z        │  (answer loading...)              │ │
│  │                      │                                   │ │
│  └──────────────────────┴──────────────────────────────────┘ │
│  > [type next question here]_                                │
│                                                               │
│  enter=submit  ctrl-y=copy response  ctrl-x=clear  esc=quit │
└──────────┬──────────────────────────────────┬────────────────┘
           │                                  │
           │ enter                            │ every 2s
           ▼                                  ▼
┌─────────────────────┐            ┌─────────────────────┐
│     submit.sh        │            │     poll.sh          │
│                      │            │                      │
│  n = next_id()       │            │  for each *.pid:     │
│  write $n.q          │            │    if process dead:  │
│  spawn agent:        │            │      mv .a.tmp → .a  │
│    claude -p > .a.tmp│            │      rm .pid         │
│  write $n.pid        │            │    fi                │
│                      │            │                      │
│  POST → fzf:reload   │            │  POST → fzf:reload   │
│  POST → fzf:refresh  │            │  POST → fzf:refresh  │
└─────────────────────┘            └─────────────────────┘
           │                                  │
           └──────────┬───────────────────────┘
                      ▼
         ┌─────────────────────┐
         │    preview.sh        │
         │                      │
         │  if $n.a exists:     │
         │    show response ✓   │
         │  elif $n.pid alive:  │
         │    show "⏳ thinking" │
         │  elif $n.err exists: │
         │    show error ✗      │
         └─────────────────────┘
```

### State Directory

Each REPL session creates a project-scoped temp directory:

```
/tmp/quick-ask-{project}-{hash}-{agent}/
├── submit.sh       ◀── dynamically generated script
├── list.sh         ◀── renders history rows for fzf
├── preview.sh      ◀── renders selected response
├── poll.sh         ◀── background poller
├── 1.q             ◀── question text
├── 1.pid           ◀── agent process ID
├── 1.a.tmp         ◀── in-progress response
├── 1.a             ◀── completed response (promoted from .tmp)
├── 2.q
├── 2.a
└── ...
```

Auto-pruned: Q&A pairs older than 8 hours are deleted on REPL start. Maximum
20 recent pairs retained.

### Component Details

**submit.sh** — Called when user presses Enter:

```bash
n=$(($(ls -1 "$qa_dir"/*.q 2>/dev/null | wc -l) + 1))
echo "$question" > "$qa_dir/$n.q"

# Spawn agent in background
case "$agent" in
  claude) claude -p --no-session-persistence "$question" > "$n.a.tmp" 2>"$n.err" ;;
  codex)  codex exec "$question" > "$n.a.tmp" 2>"$n.err" ;;
  gemini) gemini -p "$question" > "$n.a.tmp" 2>"$n.err" ;;
esac &
echo $! > "$qa_dir/$n.pid"
```

**poll.sh** — Background process running every 2 seconds:

```bash
while true; do
  changed=false
  for pidfile in "$qa_dir"/*.pid; do
    pid=$(cat "$pidfile")
    if ! kill -0 "$pid" 2>/dev/null; then
      n="${pidfile%.pid}"
      mv "$n.a.tmp" "$n.a" 2>/dev/null
      rm "$pidfile"
      changed=true
    fi
  done
  if $changed; then
    # Notify fzf to refresh via HTTP
    curl -s -XPOST "localhost:$FZF_PORT" -d 'reload(...)' >/dev/null
    curl -s -XPOST "localhost:$FZF_PORT" -d 'refresh-preview' >/dev/null
  fi
  sleep 2
done
```

**preview.sh** — Shows response for selected item:

```bash
if [[ -f "$n.a" ]]; then
  cat "$n.a"                    # Complete response
elif [[ -f "$n.pid" ]] && kill -0 "$(cat "$n.pid")" 2>/dev/null; then
  echo "⏳ thinking..."          # Agent still running
  cat "$n.a.tmp" 2>/dev/null    # Show partial output
elif [[ -f "$n.err" ]]; then
  echo "✗ Error:"
  cat "$n.err"                  # Show error output
fi
```

### FZF HTTP Polling

The REPL uses fzf's `--listen` flag to expose an HTTP endpoint:

```bash
fzf --listen 127.0.0.1:0 ...  # Port 0 = OS assigns random port
```

The assigned port is captured and passed to `submit.sh` and `poll.sh`. They use
`curl -XPOST` to trigger fzf actions like `reload(...)` and `refresh-preview`
without requiring the user to interact.

### Lifecycle

```
1.  User presses prefix+a (tmux popup)
2.  dot_quick_ask claude starts
3.  Creates qa_dir, writes helper scripts
4.  Launches fzf with --listen
5.  Starts poll.sh in background
6.  User types question → Enter
7.  submit.sh runs → agent spawned in background
8.  List shows "⏳ Explain Z"
9.  User can type next question immediately
10. poll.sh detects agent exit → promotes .a.tmp → .a
11. List updates to "✓ Explain Z", preview shows response
12. User presses ctrl-y → response copied to clipboard
13. User presses Esc → cleanup trap kills all agent processes
```

### Cleanup

A trap ensures background processes are killed on exit:

```bash
cleanup() {
  kill "$poll_pid" 2>/dev/null
  for pidfile in "$qa_dir"/*.pid; do
    kill "$(cat "$pidfile")" 2>/dev/null
  done
}
trap cleanup EXIT
```

## Key Files

| File | Role |
|------|------|
| `zsh/.zshrc.local` (lines 658-817) | `dot_quick_ask` function |
| `tmux/.tmux.conf.local` (lines 450-459) | Popup keybindings |

## See Also

- [06-tmux-agent-orchestration.md](06-tmux-agent-orchestration.md) — how popups are triggered
- [05-fzf-picker-pattern.md](05-fzf-picker-pattern.md) — underlying fzf conventions
- [08-agent-dashboard.md](08-agent-dashboard.md) — monitoring full agent sessions
