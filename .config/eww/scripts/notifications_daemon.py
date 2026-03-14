#!/usr/bin/env python3
import sys
import json
import os
import subprocess

CACHE_FILE = os.path.expanduser("~/.config/eww/scripts/notifications.json")

def load_data():
    if not os.path.exists(CACHE_FILE):
        return {"count": 0, "notifications": [], "popups": []}
    try:
        with open(CACHE_FILE, 'r') as f:
            return json.load(f)
    except:
        return {"count": 0, "notifications": [], "popups": []}

def save_and_update(data):
    with open(CACHE_FILE, 'w') as f:
        json.dump(data, f)
    # This sends the data directly to your Eww variable
    subprocess.run(["eww", "update", f"notification_data={json.dumps(data)}"])

def add_notification():
    # Dunst passes: app, summary, body, icon, urgency, id, actions
    # Ensure we have enough arguments
    if len(sys.argv) < 8: return
    
    app, summary, body, icon, urgency, nid, actions_raw = sys.argv[2:9]
    
    data = load_data()
    
    # Parse actions: "yes,Yes,no,No" -> [["yes", "Yes"], ["no", "No"]]
    act_list = actions_raw.split(',') if actions_raw else []
    actions = [act_list[i:i+2] for i in range(0, len(act_list), 2)]

    new_notif = {
        "id": nid,
        "app": app,
        "summary": summary,
        "body": body,
        "image": icon if (icon and os.path.exists(icon)) else "null",
        "actions": actions
    }

    # Add to history (top)
    data["notifications"].insert(0, new_notif)
    data["notifications"] = data["notifications"][:20]
    data["count"] = len(data["notifications"])
    
    # Also add to popups for the temporary toast
    data["popups"].append(new_notif)
    
    save_and_update(data)

def close_notification():
    nid = sys.argv[2]
    subprocess.run(["dunstctl", "close", str(nid)])
    data = load_data()
    data["notifications"] = [n for n in data["notifications"] if str(n["id"]) != str(nid)]
    data["popups"] = [p for p in data["popups"] if str(p["id"]) != str(nid)]
    data["count"] = len(data["notifications"])
    save_and_update(data)

if __name__ == "__main__":
    if len(sys.argv) < 2:
        # If called without args, just output current JSON (good for debugging)
        print(json.dumps(load_data()))
        sys.exit(0)

    cmd = sys.argv[1]
    if cmd == "add": add_notification()
    elif cmd == "close": close_notification()
    elif cmd == "clear":
        save_and_update({"count": 0, "notifications": [], "popups": []})
        subprocess.run(["dunstctl", "history-clear"])