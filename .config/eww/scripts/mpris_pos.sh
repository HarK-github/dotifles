#!/bin/bash

# Function to output current position JSON
get_pos() {
    # Get the primary player (you can specify a name if you prefer)
    player=$(playerctl metadata --format '{{playerName}}' 2>/dev/null)
    
    if [ -n "$player" ]; then
        pos=$(playerctl position 2>/dev/null || echo 0)
        # Remove decimals for math/jq compatibility
        pos_int=${pos%.*}
        # Formats position as M:SS
        pos_str=$(playerctl metadata -f "{{duration(position)}}" 2>/dev/null || echo "0:00")
        
        echo "{\"$player\": {\"position\": $pos_int, \"positionStr\": \"$pos_str\"}}"
    else
        echo "{}"
    fi
}

get_pos