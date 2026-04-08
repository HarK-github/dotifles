#!/bin/bash

# Get the current state (true/false)
STATE=$(eww get open_control_center)

if [ "$STATE" == "true" ]; then
    # 1. Update the variable first
    eww update open_control_center=false
    # 2. Close the actual window
    eww close control_center
else
    # 1. Update the variable
    eww update open_control_center=true
    # 2. Open the window
    eww open control_center
fi