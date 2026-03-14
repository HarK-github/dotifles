#!/bin/bash

get_wifi_info() {
	# Get signal strength (0-100)
	# The 'grep' looks for the line starting with '*' (the active connection)
	signal=$(nmcli -f IN-USE,SIGNAL dev wifi | grep '^\*' | awk '{print $2}')

	# Get the ESSID of the active connection
	essid=$(nmcli -t -f active,ssid dev wifi | grep '^yes' | cut -d':' -f2 | sed 's/"/\\"/g')

	# Fallback for empty values
	[[ -z "$signal" ]] && signal="0"
	[[ -z "$essid" ]] && essid="Disconnected"

	echo "{\"essid\": \"$essid\", \"signal\": \"$signal\"}"
}

# Initial call
get_wifi_info

# Instead of 'ip monitor', use a loop with a sleep interval
# This ensures signal strength updates even if the link stays 'up'
while true; do
	get_wifi_info
	sleep 5
done

