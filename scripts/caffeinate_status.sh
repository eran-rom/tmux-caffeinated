#!/usr/bin/env bash
# Prints the caffeinate status indicator for the tmux status line.
# Output is empty when caffeinate is not running (unless an "off" text is set),
# so the separator never lingers on its own.

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/helpers.sh
source "$CURRENT_DIR/helpers.sh"

main() {
	local sep
	# Printed right after the indicator, but only when the indicator is shown —
	# so it disappears along with the pill when caffeinate isn't running. Empty
	# by default: no separator unless the user opts in.
	sep="$(get_tmux_option "@caffeinate_separator" "")"

	if ! caffeinate_is_running; then
		# "off" state: emit the optional off text (empty by default).
		local off_text
		off_text="$(get_tmux_option "@caffeinate_off_text" "")"
		# Nothing to show -> emit nothing at all, separator included.
		[ -z "$off_text" ] && return
		printf '%s%s' "$off_text" "$sep"
		return
	fi

	# "on" state.
	# Default uses a Nerd Font coffee glyph (U+F0F4, UTF-8 EF 83 B4) + label.
	local coffee=$'\357\203\264'
	local on_text on_style
	on_text="$(get_tmux_option "@caffeinate_on_text" "${coffee} CAFFEINATED")"
	on_style="$(get_tmux_option "@caffeinate_on_style" "reverse,bold")"

	if [ -n "$on_style" ]; then
		# Theme-agnostic default: `reverse` swaps the theme's own fg/bg, so
		# the indicator always contrasts with the status bar on any theme.
		# (Set an explicit colour with e.g. `@caffeinate_on_style 'fg=colour208,bold'`.)
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
				"$lcap" "$on_style" "$on_text" "$rcap"
		else
			# Plain (square) highlighted pill.
			printf '#[%s] %s #[default]' "$on_style" "$on_text"
		fi
	else
		printf '%s' "$on_text"
	fi
	printf '%s' "$sep"
}

main
