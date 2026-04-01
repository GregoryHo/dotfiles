# shellcheck shell=bash
# Show running AI agent count in tmux status bar.
# Hidden (empty output) when no agents are running.
# Detects agents via process tree (child process of each pane's shell).

run_segment() {
	local pane_pids
	pane_pids=$(tmux list-panes -a -F '#{pane_pid}' 2>/dev/null | tr '\n' '|' | sed 's/|$//')
	[ -z "$pane_pids" ] && return 0

	local agents
	agents=$(ps -eo ppid= -o args= 2>/dev/null | awk -v pids="$pane_pids" '
		BEGIN { n = split(pids, p, "|"); for (i = 1; i <= n; i++) pane[p[i]] = 1 }
		!($1 in pane) { next }
		{
			a = ""
			if ($2 == "claude" || $2 == "codex" || $2 == "gemini") a = $2
			if (a == "") for (i = 2; i <= NF; i++) {
				if ($i ~ /\/claude$/) { a = "claude"; break }
				if ($i ~ /\/codex$/)  { a = "codex";  break }
				if ($i ~ /\/gemini$/) { a = "gemini"; break }
			}
			if (a == "claude") c++
			else if (a == "codex") o++
			else if (a == "gemini") g++
		}
		END {
			parts=""
			if (c>0) parts = parts (parts=="" ? "" : " ") "C" (c>1 ? ":" c : "")
			if (o>0) parts = parts (parts=="" ? "" : " ") "O" (o>1 ? ":" o : "")
			if (g>0) parts = parts (parts=="" ? "" : " ") "G" (g>1 ? ":" g : "")
			if (parts != "") print parts
		}
	')
	[ -n "$agents" ] && echo "$agents"
	return 0
}
