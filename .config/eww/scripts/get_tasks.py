#!/usr/bin/env python3
import json
import subprocess
import sys
import socket
import os
import gi

# Requires 'python-gobject' package in Linux
gi.require_version('Gtk', '3.0')
from gi.repository import Gtk

def get_icon(class_name):
    """Fetch the absolute path to the system icon using the GTK IconTheme."""
    theme = Gtk.IconTheme.get_default()
    
    # Try looking up the exact class name
    icon_info = theme.lookup_icon(class_name.lower(), 48, 0)
    if icon_info: return icon_info.get_filename()
    
    # Fallback if no icon matches the Hyprland class
    icon_info = theme.lookup_icon("application-x-executable", 48, 0)
    if icon_info: return icon_info.get_filename()
    
    return ""

def print_tasks():
    """Builds the JSON array required by the Yuck widget."""
    try:
        out = subprocess.check_output(["hyprctl", "clients", "-j"], stderr=subprocess.DEVNULL)
        clients = json.loads(out)
    except Exception:
        clients = []
        
    tasks = {}
    for c in clients:
        cls = c.get("class", "")
        # Filter out empty classes or hidden background layers
        if not cls: continue
        
        if cls not in tasks:
            tasks[cls] = {
                "class": cls,
                "count": 0,
                "workspace": [],
                "address": [],
                "icon": get_icon(cls),
                "exec": cls 
            }
            
        tasks[cls]["count"] += 1
        tasks[cls]["workspace"].append(c.get("workspace", {}).get("id", 1))
        tasks[cls]["address"].append(c.get("address"))
        
    print(json.dumps(list(tasks.values())))
    sys.stdout.flush()

def main():
    # Initial print for when EWW first boots
    print_tasks()
    
    signature = os.environ.get("HYPRLAND_INSTANCE_SIGNATURE")
    if not signature:
        return
        
    sock_path = f"/tmp/hypr/{signature}/.socket2.sock"
    
    # Listen to Hyprland's IPC socket for events
    with socket.socket(socket.AF_UNIX, socket.SOCK_STREAM) as s:
        try:
            s.connect(sock_path)
            while True:
                data = s.recv(4096)
                if not data: break
                
                # Only update the JSON if windows were opened, closed, or moved
                events = [b"openwindow", b"closewindow", b"movewindow"]
                if any(event in data for event in events):
                    print_tasks()
        except Exception:
            pass

if __name__ == "__main__":
    main()