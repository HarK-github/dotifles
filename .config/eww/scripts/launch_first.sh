#!/bin/bash

# 1. Ask EWW for the current state of apps
# 2. Use JQ to get the first filtered desktop file
# 3. If it's null or empty, jq returns nothing
APP_TO_LAUNCH=$(eww get apps | jq -r '.filtered[0].desktop // empty')

# If we found an app name, launch it
if [ ! -z "$APP_TO_LAUNCH" ]; then
	gtk-launch "$APP_TO_LAUNCH" &
fi

# Always close the launcher
~/.config/eww/scripts/toggle_launcher.sh close &
