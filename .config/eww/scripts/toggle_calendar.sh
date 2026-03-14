#!/bin/bash

# Get current state
STATE=$(eww get show_calendar)
# Match this to your ANIM_DURATION (500ms = 0.5s)
DURATION=0.5

open_calendar() {
    # 1. Start the window process
    if [[ -z $(eww windows | grep '*calendar_popup') ]]; then
        eww open calendar_popup
    fi
    # 2. Let GTK initialize the window for a split second
    sleep 0.05
    # 3. Slide it UP
    eww update show_calendar=true
}

close_calendar() {
    # 1. Slide it DOWN
    eww update show_calendar=false
    # 2. Wait for the 500ms animation to complete
    sleep $DURATION
    # 3. Kill the window process so it doesn't block other windows
    eww close calendar_popup
}

case $STATE in
    true)
        close_calendar ;;
    false)
        open_calendar ;;
esac