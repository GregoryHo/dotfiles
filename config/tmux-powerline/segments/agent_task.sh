# shellcheck shell=bash
# Show the current window's agent task name in tmux status bar.
# Hidden when no task is set (non-agent windows).

run_segment() {
	local task
	task=$(tmux display-message -p '#{@agent_task}' 2>/dev/null)
	[ -z "$task" ] || [ "$task" = "-" ] && return 0
	echo "$task"
	return 0
}
