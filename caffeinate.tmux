#!/usr/bin/env bash
# Entry point for tmux-caffeinated.
# Replaces the #{caffeinate_status} placeholder in status-left / status-right
# with a live call to the status script.

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

PLACEHOLDER="\#{caffeinate_status}"
SCRIPT="#($CURRENT_DIR/scripts/caffeinate_status.sh)"

# Substitute the placeholder in a given status option (status-left/status-right).
do_interpolation() {
	local string="$1"
	echo "${string/$PLACEHOLDER/$SCRIPT}"
}

update_tmux_option() {
	local option="$1"
	local value
	value="$(tmux show-option -gqv "$option")"
	local new_value
	new_value="$(do_interpolation "$value")"
	tmux set-option -gq "$option" "$new_value"
}

main() {
	update_tmux_option "status-right"
	update_tmux_option "status-left"
}

main
