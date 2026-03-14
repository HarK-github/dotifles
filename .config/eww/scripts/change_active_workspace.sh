#!/bin/bash
# ~/.config/eww/scripts/change_active_workspace.sh

# This script handles scrolling on workspaces
# $1 is scroll direction (up/down)
# $2 is current workspace

direction=$1
current=$2

if [ "$direction" = "up" ]; then
    next=$((current + 1))
    hyprctl dispatch workspace $next
elif [ "$direction" = "down" ]; then
    prev=$((current - 1))
    [ $prev -gt 0 ] && hyprctl dispatch workspace $prev
fi