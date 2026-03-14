#!/usr/bin/python3
import gi
gi.require_version("GdkPixbuf", "2.0")
gi.require_version("Gtk", "3.0")

import dbus
import dbus.service
from dbus.mainloop.glib import DBusGMainLoop
from gi.repository import GLib
import datetime
import os
import typing
import sys
import json
from gi.repository import Gtk, GdkPixbuf

cache_dir = f"{os.getenv('HOME')}/.cache/notify_img_data"
log_file = f"{os.getenv('HOME')}/.cache/notifications.json"
os.makedirs(cache_dir, exist_ok=True)
active_popups = {}

class NotificationDaemon(dbus.service.Object):
    def __init__(self):
        bus_name = dbus.service.BusName("org.freedesktop.Notifications", dbus.SessionBus())
        dbus.service.Object.__init__(self, bus_name, "/org/freedesktop/Notifications")
        self.dnd = False
        GLib.timeout_add_seconds(60, self.cleanup_old_notifications)

    @dbus.service.method("org.freedesktop.Notifications", in_signature="susssasa{sv}i", out_signature="u")
    def Notify(self, app_name, replaces_id, app_icon, summary, body, actions, hints, timeout):
        replaces_id = int(replaces_id)
        if replaces_id != 0:
            id = replaces_id
        else:
            log_data = self.read_log_file()
            id = log_data['notifications'][0]['id'] + 1 if log_data['notifications'] else 1

        acts = [[str(actions[i]), str(actions[i + 1])] for i in range(0, len(actions), 2)]

        details = {
            "id": id,
            "app": str(app_name),
            "summary": str(summary),
            "body": str(body),
            "time": datetime.datetime.now().strftime("%H:%M"),
            "urgency": hints["urgency"] if "urgency" in hints else 1,
            "actions": acts,
            "timestamp": datetime.datetime.now().timestamp()
        }

        if app_icon.strip():
            details["image"] = app_icon if os.path.isfile(app_icon) else self.get_gtk_icon(app_icon)
        else:
            details["image"] = None

        if "image-data" in hints:
            details["image"] = f"{cache_dir}/{details['id']}.png"
            self.save_img_byte(hints["image-data"], details["image"])

        self.save_notifications(details)
        if not self.dnd:
            self.save_popup(details)
        return id

    def write_log_file(self, data):
        output_json = json.dumps(data)
        with open(log_file, "w") as log:
            log.write(output_json)
        # CRITICAL: Print for Eww to see
        print(output_json, flush=True)

    def read_log_file(self):
        try:
            with open(log_file, "r") as log:
                return json.load(log)
        except:
            return {"count": 0, "notifications": [], "popups": []}

    def save_notifications(self, notification):
        current = self.read_log_file()
        current["notifications"].insert(0, notification)
        current["count"] = len(current["notifications"])
        self.write_log_file(current)

    @dbus.service.method("org.freedesktop.Notifications", in_signature="", out_signature="")
    def ClearAll(self):
        self.write_log_file({"count": 0, "notifications": [], "popups": []})

    def save_popup(self, notification):
        current = self.read_log_file()
        current["popups"].append(notification)
        self.write_log_file(current)
        GLib.timeout_add_seconds(5, self.DismissPopup, notification["id"])

    @dbus.service.method("org.freedesktop.Notifications", in_signature="u", out_signature="")
    def DismissPopup(self, id):
        current = self.read_log_file()
        current["popups"] = [n for n in current["popups"] if n["id"] != id]
        self.write_log_file(current)
        return False

    @dbus.service.method("org.freedesktop.Notifications", in_signature="u", out_signature="")
    def CloseNotification(self, id):
        current = self.read_log_file()
        current["notifications"] = [n for n in current["notifications"] if n["id"] != id]
        current["count"] = len(current["notifications"])
        self.write_log_file(current)
        self.DismissPopup(id)

    def get_gtk_icon(self, icon_name):
        theme = Gtk.IconTheme.get_default()
        icon_info = theme.lookup_icon(icon_name, 128, 0)
        return icon_info.get_filename() if icon_info else None

    def cleanup_old_notifications(self):
        current = self.read_log_file()
        now = datetime.datetime.now().timestamp()
        current["notifications"] = [n for n in current["notifications"] if now - n.get("timestamp", now) < 86400]
        current["count"] = len(current["notifications"])
        self.write_log_file(current)
        return True

def main():
    DBusGMainLoop(set_as_default=True)
    loop = GLib.MainLoop()
    daemon = NotificationDaemon()
    # Initial print for Eww startup
    print(json.dumps(daemon.read_log_file()), flush=True)
    loop.run()

if __name__ == "__main__":
    main()
