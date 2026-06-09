#!/usr/bin/env bash
# Prints the caffeinate status indicator for the tmux status line.
# Output is empty when caffeinate is not running (unless an "off" icon is set).

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/helpers.sh
source "$CURRENT_DIR/helpers.sh"

main() {
	if ! caffeinate_is_running; then
		# "off" state: emit the optional off icon (empty by default).
		local off_icon off_color
		off_icon="$(get_tmux_option "@caffeinate_off_icon" "")"
		off_color="$(get_tmux_option "@caffeinate_off_color" "")"
		if [ -n "$off_icon" ] && [ -n "$off_color" ]; then
			printf '#[fg=%s]%s#[default]' "$off_color" "$off_icon"
		else
			printf '%s' "$off_icon"
		fi
		return
	fi

	# "on" state.
	# Default uses a Nerd Font coffee glyph (U+F0F4, UTF-8 EF 83 B4) + label.
	local coffee=$'\357\203\264'
	local on_icon on_color on_style
	on_icon="$(get_tmux_option "@caffeinate_on_icon" "${coffee} CAFFEINATED")"
	on_color="$(get_tmux_option "@caffeinate_on_color" "")"
	on_style="$(get_tmux_option "@caffeinate_on_style" "reverse,bold")"

	if [ -n "$on_color" ]; then
		# Explicit colour wins, if the user set one.
		printf '#[fg=%s]%s#[default]' "$on_color" "$on_icon"
	elif [ -n "$on_style" ]; then
		# Theme-agnostic default: `reverse` swaps the theme's own fg/bg, so
		# the indicator always contrasts with the status bar on any theme.
		local round
		round="$(get_tmux_option "@caffeinate_round" "on")"
		if [ "$round" = "on" ]; then
			# Rounded pill using powerline half-circle caps (Nerd Font).
			# The caps are drawn in the DEFAULT style: their solid half is the
			# theme's fg colour — which is exactly the reverse pill's bg colour,
			# so the rounded ends blend into the body on any theme.
			local lcap=$'\356\202\266'  # U+E0B6  (left half circle)
			local rcap=$'\356\202\264'  # U+E0B4  (right half circle)
			printf '#[default]%s#[%s] %s #[default]%s' \
				"$lcap" "$on_style" "$on_icon" "$rcap"
		else
			# Plain (square) highlighted pill.
			printf '#[%s] %s #[default]' "$on_style" "$on_icon"
		fi
	else
		printf '%s' "$on_icon"
	fi
}

main
