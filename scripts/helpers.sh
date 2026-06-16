#!/usr/bin/env bash
# Shared helpers for tmux-caffeinated.

# Read a tmux user option, falling back to a default when unset/empty.
#   get_tmux_option "@caffeinate_on_text" "CAFFEINATED"
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

# Is any keep-awake utility currently running?  Returns 0 (true) / 1 (false).
# macOS: caffeinate.  Linux: systemd-inhibit, caffeine.  Override the matched
# set with e.g. `set -g @caffeinate_process 'caffeinate|systemd-inhibit'`.
# ponytail: process-name match; upgrade path is `systemd-inhibit --list` parsing
# if DE (GNOME/KDE) inhibits without a wrapper process ever need detecting.
caffeinate_is_running() {
	local pattern
	pattern="$(get_tmux_option "@caffeinate_process" "caffeinate|systemd-inhibit|caffeine")"
	pgrep -x "$pattern" >/dev/null 2>&1
}
