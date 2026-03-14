#!/usr/bin/python3

import glob
import sys
import os
import json
import subprocess
import time
from pathlib import Path

try:
    import gi
    gi.require_version("Gtk", "3.0")
    from gi.repository import Gtk
except ImportError:
    print("Please install python3-gi: sudo apt install python3-gi", file=sys.stderr)
    sys.exit(1)

from configparser import RawConfigParser

# Cache files
PINNED_CACHE = os.path.expanduser("~/.cache/eww-pinned.json")
FULL_APP_CACHE = os.path.expanduser("~/.cache/eww-all-apps.json")
CACHE_MAX_AGE = 86400  # 24 hours in seconds

DESKTOP_DIRS = [
    "/usr/share/applications",
    "/usr/local/share/applications",
    os.path.expanduser("~/.local/share/applications"),
    "/var/lib/snapd/desktop/applications",
    "/snap/*/current/meta/gui"
]

def get_gtk_icon(icon_name):
    """Get icon path from GTK icon theme (cached per session)"""
    if not icon_name:
        return None
    if os.path.isabs(icon_name) and os.path.exists(icon_name):
        return icon_name
    try:
        theme = Gtk.IconTheme.get_default()
        for size in [48, 64, 128]:
            icon_info = theme.lookup_icon(icon_name, size, 0)
            if icon_info is not None:
                return icon_info.get_filename()
    except:
        pass
    return None

def parse_desktop_file(file_path):
    """Safely parse a desktop file"""
    try:
        parser = RawConfigParser()
        with open(file_path, 'r', encoding='utf-8') as f:
            parser.read_file(f)
        if not parser.has_section("Desktop Entry"):
            return None
        if parser.getboolean("Desktop Entry", "NoDisplay", fallback=False):
            return None
        if parser.get("Desktop Entry", "Type", fallback="") != "Application":
            return None
        if parser.getboolean("Desktop Entry", "Hidden", fallback=False):
            return None

        app_name = parser.get("Desktop Entry", "Name", fallback="Unknown")
        # Try locale-specific name
        import locale
        current_locale = locale.getlocale()[0]
        if current_locale:
            locale_key = f"Name[{current_locale}]"
            if parser.has_option("Desktop Entry", locale_key):
                app_name = parser.get("Desktop Entry", locale_key)

        icon_name = parser.get("Desktop Entry", "Icon", fallback=None)
        icon_path = get_gtk_icon(icon_name) if icon_name else None

        return {
                "name": app_name,
                "icon": icon_path if icon_path and os.path.exists(icon_path) else "",
                "desktop": os.path.basename(file_path),
                "exec": parser.get("Desktop Entry", "Exec", fallback=""),
        }
    except Exception:
        return None

def scan_all_apps():
    """Perform a full scan of all desktop files (slow, called rarely)"""
    entries = []
    processed_files = set()
    for desktop_dir in DESKTOP_DIRS:
        if not os.path.exists(desktop_dir):
            continue
        if '*' in desktop_dir:
            for path in glob.glob(desktop_dir):
                if os.path.isdir(path):
                    for file_path in glob.glob(os.path.join(path, "*.desktop")):
                        if file_path not in processed_files:
                            entry = parse_desktop_file(file_path)
                            if entry:
                                entries.append(entry)
                                processed_files.add(file_path)
            continue
        for file_path in glob.glob(os.path.join(desktop_dir, "*.desktop")):
            if file_path in processed_files:
                continue
            entry = parse_desktop_file(file_path)
            if entry:
                entries.append(entry)
                processed_files.add(file_path)

    # Deduplicate by desktop filename
    unique = {}
    for e in entries:
        if e['desktop'] not in unique:
            unique[e['desktop']] = e
    sorted_entries = sorted(unique.values(), key=lambda x: x["name"].lower())
    return sorted_entries

def get_desktop_entries():
    """Return full app list, using cache if fresh, otherwise scan and cache."""
    # Try to load from cache first
    if os.path.exists(FULL_APP_CACHE):
        try:
            mtime = os.path.getmtime(FULL_APP_CACHE)
            if time.time() - mtime < CACHE_MAX_AGE:
                with open(FULL_APP_CACHE, 'r', encoding='utf-8') as f:
                    apps_list = json.load(f)
                    return {
                        "apps": apps_list,
                        "pinned": read_pinned_cache(),
                        "search": False,
                        "filtered": []
                    }
        except Exception:
            pass  # fall through to rescan

    # Cache missing or stale – perform full scan
    apps_list = scan_all_apps()
    try:
        with open(FULL_APP_CACHE, 'w', encoding='utf-8') as f:
            json.dump(apps_list, f, indent=2, ensure_ascii=False)
    except Exception:
        pass

    return {
        "apps": apps_list,
        "pinned": read_pinned_cache(),
        "search": False,
        "filtered": []
    }

def read_pinned_cache():
    """Read pinned apps from PINNED_CACHE"""
    try:
        with open(PINNED_CACHE, 'r', encoding='utf-8') as f:
            return json.load(f)
    except (FileNotFoundError, json.JSONDecodeError):
        empty = []
        try:
            with open(PINNED_CACHE, 'w', encoding='utf-8') as f:
                json.dump(empty, f, indent=2)
        except:
            pass
        return empty

def write_pinned_cache(entries):
    """Write pinned apps to PINNED_CACHE"""
    try:
        with open(PINNED_CACHE, 'w', encoding='utf-8') as f:
            json.dump(entries, f, indent=2, ensure_ascii=False)
    except Exception:
        pass

def filter_entries(entries, query):
    """Filter apps based on search query (fast, uses cached app list)"""
    if not query or not query.strip():
        return []
    query = query.lower().strip()
    return [e for e in entries["apps"] if query in e["name"].lower()][:30]

def update_eww(entries):
    """Safely update EWW with JSON data"""
    try:
        entries.setdefault("apps", [])
        entries.setdefault("pinned", [])
        entries.setdefault("filtered", [])
        entries.setdefault("search", False)

        json_str = json.dumps(entries, ensure_ascii=False)

        cmd = f'eww update apps=\'{json_str}\''

        subprocess.run(cmd, shell=True)

    except Exception as e:
        print("EWW UPDATE ERROR:", e)
def add_pinned_entry(name, icon, desktop):
    """Add an app to pinned list"""
    cache = read_pinned_cache()
    if any(c['desktop'] == desktop for c in cache):
        return
    cache.insert(0, {"name": name, "icon": icon, "desktop": desktop})
    write_pinned_cache(cache)
    # Refresh the main view (pinned section updates)
    entries = get_desktop_entries()
    update_eww(entries)

def remove_pinned_entry(desktop):
    """Remove an app from pinned list"""
    cache = read_pinned_cache()
    cache = [c for c in cache if c['desktop'] != desktop]
    write_pinned_cache(cache)
    entries = get_desktop_entries()
    update_eww(entries)

if __name__ == "__main__":
    # Optionally suppress stderr to avoid GTK warnings (uncomment if desired)
    # sys.stderr = open(os.devnull, 'w')

    try:
        if len(sys.argv) > 2:
            if sys.argv[1] == "--query":
                query = " ".join(sys.argv[2:])
                entries = get_desktop_entries()
                if query and query.strip():
                    filtered = filter_entries(entries, query)
                    entries.update({"search": True, "filtered": filtered})
                else:
                    entries.update({"search": False, "filtered": []})
                update_eww(entries)
            elif sys.argv[1] == "--add-pin" and len(sys.argv) >= 5:
                add_pinned_entry(sys.argv[2], sys.argv[3], sys.argv[4])
            elif sys.argv[1] == "--remove-pin" and len(sys.argv) >= 3:
                remove_pinned_entry(sys.argv[2])
        else:
            # Initial load
            update_eww(get_desktop_entries())
    except Exception as e:
        # Fallback to empty structure
        update_eww({"apps": [], "pinned": [], "search": False, "filtered": []})
