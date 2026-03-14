#!/bin/bash

# 1. Check if the file exists
if [ ! -f "$HOME/.config/eww/scripts/get_tasks.py" ]; then
    echo "ERROR: Python script not found at $HOME/.config/eww/scripts/get_tasks.py"
    exit 1
fi

run_task_script() {
    # REMOVED 2>/dev/null so we can see errors!
    /usr/bin/python3 -u "$HOME/.config/eww/scripts/get_tasks.py"
}

echo "--- STEP 1: Testing Initial Run ---"
run_task_script
echo "--- STEP 1 COMPLETE ---"

echo "--- STEP 2: Starting Socat Loop ---"
echo "Listening to: $XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock"

socat -u UNIX-CONNECT:"$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock" - | while read -r line; do
    echo "Raw Event Received: $line" # This confirms socat is talking to bash
    case "$line" in
        *"openwindow"*|*"closewindow"*|*"movewindow"*|*"activewindow"*|*"workspace"*)
            echo "Match found! Updating..."
            run_task_script
            ;;
    esac
done