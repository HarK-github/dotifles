#!/bin/bash

get_workspaces() {
    local clients=$(hyprctl clients -j)
    
    hyprctl workspaces -j | jq -c --argjson clients "$clients" '
        {
            "firefox": "",
            "firefoxdeveloperedition": "",
            "librewolf": "",
            "zen-alpha": "",
            "zen-browser": "",
            "org.mozilla.firefox": "",
            
            "kitty": "󰄛",
            "alacritty": "",
            "foot": "",
            "wezterm": "",
            "gnome-terminal": "",
            "konsole": "",
            
            "code": "󰨞",
            "code-oss": "󰨞",
            "codium": "󰨞",
            "vscode": "󰨞",
            
            "spotify": "",
            "discord": "󰙯",
            "vesktop": "󰙯",
            
            "thunar": "󰉋",
            "nautilus": "󰉋",
            "dolphin": "󰉋",
            "nemo": "󰉋",
            "pcmanfm": "󰉋",
            
            "brave-browser": "令",
            "google-chrome": "",
            "chromium": "",
            "opera": "",
            "vivaldi": "",
            
            "slack": "",
            "telegramdesktop": "",
            "teams": "󰊻",
            "zoom": "",
            
            "libreoffice": "󰈙",
            "libreoffice-writer": "󰈙",
            "libreoffice-calc": "󰈛",
            "libreoffice-impress": "󰈚",
            
            "gimp": "",
            "inkscape": "",
            "blender": "󰂫",
            
            "vlc": "󰕼",
            "mpv": "",
            "celluloid": "",
            
            "steam": "",
            "lutris": "󰺵",
            "heroic": "󰺵",
            
            "virt-manager": "󰌓",
            "vmware": "󰌓",
            "virtualbox": "󰌓",
            
            "obs": "󰋼",
            "kdenlive": "󰋼",
            
            "gparted": "󰋊",
            "gnome-disks": "󰋊",
            "baobab": "󰋊",
            
            "calibre": "󰂯",
            "zathura": "󰈇",
            "evince": "󰈇",
            
            "pavucontrol": "󰓃",
            "pulseaudio": "󰓃",
            
            "nm-connection-editor": "󰤨",
            "blueman-manager": "󰂯",
            
            "org.gnome.Calculator": "󰃬",
            "gnome-calendar": "󰃭",
            "org.gnome.Calendar": "󰃭",
            
            "keepassxc": "󰟵",
            "bitwarden": "󰟵",
            
            "default": "",
            "numbered": ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10"]
        }as $icons |
        # Generate default slots 1-6
        [range(1; 7) | {id: ., windows: 0}] as $base |
        # Merge actual workspaces into the base slots
        ($base + map({id: .id, windows: .windows})) | unique_by(.id) | 
        [ .[] | .id as $ws_id |
          # Find windows on this workspace
          ($clients | map(select(.workspace.id == $ws_id)) | map(.class | ascii_downcase)) as $window_classes |
          ($window_classes | map($icons[.] // "󰘔")) as $window_icons |
          ($window_icons | length) as $window_count |
          
          # Fixed Logic for the Display Label
          (if $window_count == 0 then
             $icons.numbered[$ws_id - 1] // ($ws_id | tostring)
          elif $window_count <= 3 then
             # 1 to 3 windows: Show Number + All Icons
             "\($ws_id) " + ($window_icons | join(" "))
          else
             # More than 3 windows: Show Number + First 3 Icons + remaining count
             "\($ws_id) " + ($window_icons[0:3] | join(" ")) + " +" + (($window_count - 3) | tostring)
          end) as $display_icon |
          
          {
            id: ($ws_id | tostring),
            occupied: ($window_count > 0),
            icon: $display_icon
          }
        ] | sort_by(.id | tonumber)'
}

# Keep your listener loop below...
# Initial output for EWW
get_workspaces

# Detect the correct socket path
# We use the variable if it exists, otherwise we search the runtime dir
SOCK_PATH="$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock"

if [ ! -S "$SOCK_PATH" ]; then
    SOCK_PATH=$(find "$XDG_RUNTIME_DIR/hypr" -name ".socket2.sock" | head -n 1)
fi

# The Listener Loop
socat -u UNIX-CONNECT:"$SOCK_PATH" - | while read -r line; do
    case "$line" in
        *"workspace>>"*|*"createworkspace>>"*|*"destroyworkspace>>"*|*"activewindow>>"*|*"closewindow>>"*|*"openwindow>>"*|*"movewindow>>"*)
            get_workspaces
            ;;
    esac
done