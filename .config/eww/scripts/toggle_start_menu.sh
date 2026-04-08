#!/bin/bash

# Use -x to match the exact process name to avoid false positives
if pgrep -x "rofi" > /dev/null; then
    killall rofi
else
    # Corrected flags: -normal-window helps prevent some "stealing" behaviors
    rofi -show drun -normal-window
fi
