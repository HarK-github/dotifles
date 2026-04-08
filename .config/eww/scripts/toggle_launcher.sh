#!/bin/bash

# Get the current state
state=$(eww get open_launcher)

# Define Python interpreter - using system Python
PYTHON_CMD="/usr/bin/python3"

# Check if system python3 exists, fallback to just python3 in PATH
if [ ! -f "$PYTHON_CMD" ]; then
	PYTHON_CMD=$(which python3)
fi

# Path to the apps.py script
APPS_SCRIPT="$HOME/.config/eww/scripts/apps.py"

open_launcher() {
	# Changed 'eww windows' to 'eww list-windows'
	if [[ -z $(eww list-windows | grep '*launcher') ]]; then
		eww open launcher
	fi
	eww update open_launcher=true
	sleep 0.5 && $PYTHON_CMD "$APPS_SCRIPT" &
}

close_launcher() {
	eww close launcher
	eww update open_launcher=false
	$PYTHON_CMD "$APPS_SCRIPT" &
}

# Make sure the apps.py script is executable
if [ ! -x "$APPS_SCRIPT" ]; then
	chmod +x "$APPS_SCRIPT"
fi

case $1 in
close)
	close_launcher
	exit 0
	;;
open)
	open_launcher
	exit 0
	;;
esac

case $state in
true)
	close_launcher
	exit 0
	;;
false)
	open_launcher
	exit 0
	;;
esac
