#!/bin/bash
base_dir="$HOME/.config/eww"
mkdir -p "$base_dir/temp"

playerctl metadata -F -f '{{playerName}}|{{title}}|{{artist}}|{{mpris:artUrl}}|{{status}}|{{mpris:length}}' 2>/dev/null | while IFS='|' read -r name title artist artUrl status length; do
   if [[ -n "$length" && "$length" =~ ^[0-9]+$ ]]; then
        length_secs=$((length / 1000000))
        length_str=$(playerctl metadata -f "{{duration(mpris:length)}}" 2>/dev/null)
    else
        length_secs=0
        length_str="0:00"
    fi
    # Handle Art
    target_art="$base_dir/temp/cover_${name}.png"
    if [[ "$artUrl" == file://* ]]; then
        cp "${artUrl#file://}" "$target_art" 2>/dev/null
    elif [[ "$artUrl" == http* ]]; then
        curl -s "$artUrl" --output "$target_art"
    else
        target_art="assets/default_music.png"
    fi

    # THE FIX: Added -c flag for compact output
    jq -c -n \
        --arg name "$name" \
        --arg title "${title:-Offline}" \
        --arg artist "${artist:-Unknown Artist}" \
        --arg artUrl "$target_art" \
        --arg status "$status" \
        --arg length "$length_secs" \
        --arg lengthStr "$length_str" \
        '{name: $name, title: $title, artist: $artist, artUrl: $artUrl, status: $status, length: $length, lengthStr: $lengthStr}'
done
