#!/bin/bash
QUERY="$1"
ALL_APPS_JSON="$HOME/.config/eww/start_menu/all_apps.json"

# Use jq to filter apps (faster than Python for JSON)
if command -v jq &> /dev/null; then
    RESULTS=$(jq --arg q "$QUERY" '[.[] | select(.name | test($q; "i"))]' "$ALL_APPS_JSON")
else
    # Fallback to Python if jq isn't available
    RESULTS=$(/usr/bin/python3 -c "
import json, sys
with open('$ALL_APPS_JSON') as f:
    apps = json.load(f)
query = '$QUERY'.lower()
results = [a for a in apps if query in a['name'].lower()]
print(json.dumps(results))
")
fi

eww update start_menu_search_results="$RESULTS"