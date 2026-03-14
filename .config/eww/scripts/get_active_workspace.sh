#!/bin/bash

# Function to get just the ID of the active workspace
get_active() {
    hyprctl activeworkspace -j | jq -r '.id'
}

# Initial output
get_active

# Use the same socket logic we found earlier
SOCK_PATH=$(find "$XDG_RUNTIME_DIR/hypr" -name ".socket2.sock" | head -n 1)

socat -u UNIX-CONNECT:"$SOCK_PATH" - | while read -r line; do
    # Only update when the workspace actually changes
    if [[ $line == *"workspace>>"* ]]; then
        get_active
    fi
done