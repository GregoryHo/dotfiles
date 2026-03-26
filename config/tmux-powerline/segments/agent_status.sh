# shellcheck shell=bash
# Show running AI agent count in tmux status bar.
# Hidden (empty output) when no agents are running.
# Detects agents by window name (agent-*) or pane foreground command.

run_segment() {
	local agents
	agents=$(tmux list-panes -a -F '#{window_name} #{pane_current_command}' 2>/dev/null |
		awk '
		/^agent-claude / || / claude$/ { c++ }
		/^agent-codex /  || / codex$/  { o++ }
		/^agent-gemini / || / gemini$/ { g++ }
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
