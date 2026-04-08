#!/bin/bash

STATE_FILE="$HOME/.cache/battery_mode"

# Function to read the current saved state
get_mode() {
    if [ ! -f "$STATE_FILE" ]; then
        echo "balanced" > "$STATE_FILE"
    fi
    cat "$STATE_FILE"
}

# Function to apply TLP settings and cycle
toggle_mode() {
    CURRENT=$(get_mode)

    case $CURRENT in
        "balanced")
            sudo tlp power-saver > /dev/null
            NEXT="power-saver"
            ;;
        "power-saver")
            sudo tlp ac > /dev/null
            NEXT="performance"
            ;;
        "performance")
            sudo tlp balanced > /dev/null
            NEXT="balanced"
            ;;
        *)
            NEXT="balanced"
            ;;
    esac

    echo "$NEXT" > "$STATE_FILE"
    # Push the change to Eww variable
    eww update battery_mode="$NEXT"
}

# Logic execution
if [ "$1" == "init" ]; then
    get_mode
else
    toggle_mode
fi