#!/bin/bash

# Use pgrep with -u $USER to make sure you only target your own process
if pgrep -x "easyeffects" > /dev/null; then
    # -q is correct for quitting, but pkill is a "brute force" backup
    easyeffects -q || pkill easyeffects
    eww update ee_enabled=false
else
    # --gapplication-service starts it as a background daemon
    easyeffects --gapplication-service & 
    eww update ee_enabled=true
fi
