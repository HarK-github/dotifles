#!/bin/bash
# Initial value
hyprctl activeworkspace -j | jq -r '.id'

# Listen for focus changes
HYPR_ADDR=$(ls /tmp/hypr/ | head -n 1)
socat -u UNIX-CONNECT:"/tmp/hypr/$HYPR_ADDR/.socket2.sock" - | while read -r line; do
    if [[ $line == *"workspace>>"* ]]; then
        hyprctl activeworkspace -j | jq -r '.id'
    fi
done