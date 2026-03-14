#!/bin/bash

get_volume() {
	# Check mute status
	muted=$(pactl get-sink-mute @DEFAULT_SINK@ | awk '{print $2}')

	# Grab the volume of the first channel only to avoid multi-line issues
	volume=$(pactl get-sink-volume @DEFAULT_SINK@ | grep -m1 'Volume:' | awk '{print $5}' | tr -d '%')

	if [ "$muted" = "yes" ]; then
		echo "muted"
	else
		# Ensure volume is a pure number; fallback to 0 if empty
		echo "${volume:-0}"
	fi
}

get_volume

# Listen for change events from PulseAudio
pactl subscribe | grep --line-buffered "sink" | while read -r line; do
	get_volume
done
