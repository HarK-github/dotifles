#!/bin/bash

# Define your preferred icon theme path
THEME_DIR="/usr/share/icons/hicolor/scalable/apps"
FALLBACK_ICON="/usr/share/icons/hicolor/scalable/apps/icon-missing.svg"

CLASS_NAME=$(echo "$1" | tr '[:upper:]' '[:lower:]')

# Try to find the icon. Adjust the path if your icons are elsewhere (e.g., ~/.local/share/icons)
ICON_PATH=$(find "$THEME_DIR" -name "${CLASS_NAME}*" -print -quit)

if [ -z "$ICON_PATH" ]; then
    echo "$FALLBACK_ICON"
else
    echo "$ICON_PATH"
fi