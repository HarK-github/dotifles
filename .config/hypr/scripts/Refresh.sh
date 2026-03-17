#!/usr/bin/env bash
# /* ---- 💫 Optimized for AGS & Eww 💫 ---- */

SCRIPTSDIR=$HOME/.config/hypr/scripts
UserScripts=$HOME/.config/hypr/UserScripts
AGS_CONFIG="$HOME/.config/ags"

# 1. Kill existing UI processes (Added 'ags')
_ps=(rofi end-rs eww ags)
for _prs in "${_ps[@]}"; do
    pkill "${_prs}"
done

# 2. Generate Colors (Optional: If using matugen or pywal)
# If your theme uses a tool to generate colors from wallpaper:
# matugen image "$1" 

# 3. Relaunch AGS
# Use -c to ensure it points to your config
if command -v ags >/dev/null; then
    ags & 
else
    echo "AGS not found, skipping..."
fi

# 4. Relaunch Eww & SwayNC
sleep 0.2
eww daemon && eww open bar &
end-rs >/dev/null 2>&1 &

# 5. Relaunch Rainbow Borders
if [ -f "${UserScripts}/RainbowBorders.sh" ]; then
    "${UserScripts}/RainbowBorders.sh" &
fi