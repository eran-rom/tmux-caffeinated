#!/usr/bin/env bash
# Shared helpers for tmux-caffeinated.

# Read a tmux user option, falling back to a default when unset/empty.
#   get_tmux_option "@caffeinate_on_icon" "CAFFEINATED"
get_tmux_option() {
	local option="$1"
	local default_value="$2"
	local value
	value="$(tmux show-option -gqv "$option")"
	if [ -z "$value" ]; then
		echo "$default_value"
	else
		echo "$value"
	fi
}

# Is caffeinate currently running?  Returns 0 (true) / 1 (false).
caffeinate_is_running() {
	pgrep -x caffeinate >/dev/null 2>&1
}
