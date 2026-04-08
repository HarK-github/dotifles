#!/usr/bin/env python3
import sys
import json
import subprocess
import os
import gi

gi.require_version('Gio', '2.0')
from gi.repository import Gio

PINNED_FILE = os.path.expanduser("~/.config/eww/pinned.json")

def get_icon_name(app_id):
    if not app_id or app_id == "null":
        return "application-x-executable"
    
    OVERRIDES = {
        "code": "vscode", 
        "org.gnome.SystemMonitor": "utilities-system-monitor",
        "kitty": "terminal",
        "brave-browser": "brave"
    }
    if app_id in OVERRIDES:
        return OVERRIDES[app_id]

    for name in [f"{app_id}.desktop", f"{app_id.lower()}.desktop"]:
        try:
            app_info = Gio.DesktopAppInfo.new(name)
            if app_info:
                icon = app_info.get_icon()
                if icon: return icon.to_string()
        except:
            continue
    return app_id

def load_pinned():
    if not os.path.exists(PINNED_FILE): return []
    try:
        with open(PINNED_FILE, 'r') as f: return json.load(f)
    except: return []

def main():
    proc = subprocess.Popen(["wlr-apps", "-mjq", "1"], stdout=subprocess.PIPE, text=True)
    pinned_ids = load_pinned()
    initial = []
    for p in pinned_ids:
        initial.append({
            "app_id": p,
            "id": "null",
            "active": False,
            "pinned": True,
            "icon": get_icon_name(p)
        })
    print(json.dumps(initial), flush=True)
    for line in proc.stdout:
        line = line.strip()
        if not line: continue
            
        try:
            running_windows = json.loads(line)
            pinned_ids = load_pinned()
            final_list = []
            
            # Create a copy of the list to track what we've "used"
            unprocessed_running = list(running_windows)

            # 1. Handle Pinned Apps
            for p_id in pinned_ids:
                # Find ALL instances of this pinned ID in running windows
                instances = [w for w in unprocessed_running if w.get("app_id") == p_id]
                
                if instances:
                    for app in instances:
                        app["icon"] = get_icon_name(p_id)
                        app["pinned"] = True
                        final_list.append(app)
                        # Remove this specific instance so it's not added again later
                        unprocessed_running.remove(app)
                else:
                    # Pinned but not running: add one placeholder icon
                    final_list.append({
                        "app_id": p_id,
                        "id": "null",
                        "active": False,
                        "pinned": True,
                        "icon": get_icon_name(p_id)
                    })

            # 2. Add remaining unpinned windows (duplicates included)
            for app in unprocessed_running:
                app_id = app.get("app_id")
                app["icon"] = get_icon_name(app_id)
                app["pinned"] = False
                final_list.append(app)

            print(json.dumps(final_list), flush=True)
            
        except json.JSONDecodeError:
            continue

if __name__ == "__main__":
    main()