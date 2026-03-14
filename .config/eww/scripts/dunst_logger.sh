import sys
import json
import os
import subprocess
import threading
import time

CACHE_FILE = os.path.expanduser("~/.config/eww/scripts/notifications.json")
# This matches your Eww variable name
EWW_VAR = "notification_data" 

def load_data():
    if not os.path.exists(CACHE_FILE):
        return {"notifications": [], "popups": [], "count": 0}
    with open(CACHE_FILE, 'r') as f:
        return json.load(f)

def save_and_update(data):
    with open(CACHE_FILE, 'w') as f:
        json.dump(data, f)
    # Update Eww state
    subprocess.run(["eww", "update", f"{EWW_VAR}={json.dumps(data)}"])

def add_notification():
    # Dunst passes: app, summary, body, icon, urgency, id, actions
    app, summary, body, icon, urgency, nid, actions_raw = sys.argv[2:]
    
    data = load_data()
    
    # Parse actions: "yes,Yes,no,No" -> [["yes", "Yes"], ["no", "No"]]
    act_list = actions_raw.split(',')
    actions = [act_list[i:i+2] for i in range(0, len(act_list), 2)] if actions_raw else []

    new_notif = {
        "id": nid,
        "app": app,
        "summary": summary,
        "body": body,
        "image": icon if os.path.exists(icon) else "null",
        "actions": actions
    }

    # Add to history (limit to 20)
    data["notifications"].insert(0, new_notif)
    data["notifications"] = data["notifications"][:20]
    data["count"] = len(data["notifications"])
    
    # Add to popups
    data["popups"].append(new_notif)
    save_and_update(data)

    # Timer to remove from popups after 5 seconds
    def remove_popup():
        time.sleep(5)
        d = load_data()
        d["popups"] = [p for p in d["popups"] if p["id"] != nid]
        save_and_update(d)
    
    threading.Thread(target=remove_popup).start()

def handle_action():
    nid, action_key = sys.argv[2], sys.argv[3]
    subprocess.run(["dunstctl", "action", nid, action_key])
    close_notification(nid)

def close_notification(nid=None):
    if nid is None: nid = sys.argv[2]
    subprocess.run(["dunstctl", "close", nid])
    data = load_data()
    data["notifications"] = [n for n in data["notifications"] if str(n["id"]) != str(nid)]
    data["popups"] = [p for p in data["popups"] if str(p["id"]) != str(nid)]
    data["count"] = len(data["notifications"])
    save_and_update(data)

def clear_all():
    subprocess.run(["dunstctl", "history-clear"])
    save_and_update({"notifications": [], "popups": [], "count": 0})

if __name__ == "__main__":
    cmd = sys.argv[1]
    if cmd == "add": add_notification()
    elif cmd == "action": handle_action()
    elif cmd == "close": close_notification()
    elif cmd == "clear": clear_all()