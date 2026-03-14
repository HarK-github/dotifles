#!/bin/bash
PINNED_JSON="$HOME/.config/eww/start_menu/pinned.json"
FILENAME="$1"

# Ensure directory exists
mkdir -p "$HOME/.config/eww/start_menu"

# Read current list
if [ -f "$PINNED_JSON" ]; then
    LIST=$(cat "$PINNED_JSON")
else
    LIST='[]'
fi

# Toggle pin status
if echo "$LIST" | grep -q "\"$FILENAME\""; then
    # Remove
    NEW_LIST=$(echo "$LIST" | jq 'map(select(. != "'"$FILENAME"'"))')
else
    # Add
    NEW_LIST=$(echo "$LIST" | jq '. + ["'"$FILENAME"'"]')
fi

# Save
echo "$NEW_LIST" > "$PINNED_JSON"

# Update EWW with new pinned data
/usr/bin/python3 "$HOME/.config/eww/scripts/start_menu_pinned.py" | \
    eww update start_menu_pinned_data="$(cat)"