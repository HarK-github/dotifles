#!/usr/bin/env python3
import os
import json
import gi
gi.require_version('Gtk', '3.0')
from gi.repository import Gtk, Gio
def get_icon_path(icon_name):
    """Resolve icon name to path, falling back to ava.jpg if nothing works."""
    # Define your custom fallback path
    ava_fallback = os.path.expanduser('~/.config/eww/ava.jpg')
    
    theme = Gtk.IconTheme.get_default()
    
    # 1. Try resolving the provided name
    if icon_name:
        if icon_name.startswith('/') and os.path.exists(icon_name):
            return icon_name
        
        icon_info = theme.lookup_icon(icon_name, 48, 0)
        if icon_info:
            return icon_info.get_filename()
            
    # 2. Try system fallback icon
    fallback_info = theme.lookup_icon("application-x-executable", 48, 0)
    if fallback_info:
        return fallback_info.get_filename()
        
    # 3. Final Boss Fallback: Your ava.jpg
    if os.path.exists(ava_fallback):
        return ava_fallback
        
    return "" # Absolute last resort (should not happen if ava.jpg exists)    """Resolve an icon name to a full path, with guaranteed crash-proof fallbacks."""
    # 1. If it's already a valid absolute path, use it.
    if icon_name and icon_name.startswith('/'):
        if os.path.exists(icon_name):
            return icon_name

    theme = Gtk.IconTheme.get_default()
    
    # 2. Try to find the requested icon via GTK
    if icon_name:
        icon_info = theme.lookup_icon(icon_name, 48, 0)
        if icon_info:
            return icon_info.get_filename()
            
    # 3. FALLBACK: Use the system's default generic application icon
    fallback_info = theme.lookup_icon("application-x-executable", 48, 0)
    if fallback_info:
        return fallback_info.get_filename()
        
    # 4. ULTIMATE FALLBACK: Generate a 1x1 transparent PNG so EWW never sees an empty string
    fallback_path = os.path.expanduser('~/.config/eww/start_menu/fallback.png')
    if not os.path.exists(fallback_path):
        import base64
        # Base64 string for a 1x1 transparent PNG
        b64 = "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNkYAAAAAYAAjCB0C8AAAAASUVORK5CYII="
        with open(fallback_path, "wb") as f:
            f.write(base64.b64decode(b64))
            
    return fallback_path
def parse_desktop_file(path):
    """Extract name, icon, and filename from a .desktop file."""
    with open(path, 'r', encoding='utf-8') as f:
        content = f.read()
    name = None
    icon = None
    hidden = False
    no_display = False
    for line in content.splitlines():
        if line.startswith('Name='):
            name = line.split('=', 1)[1].strip()
        elif line.startswith('Icon='):
            icon = line.split('=', 1)[1].strip()
        elif line.startswith('Hidden='):
            hidden = line.split('=', 1)[1].strip().lower() == 'true'
        elif line.startswith('NoDisplay='):
            no_display = line.split('=', 1)[1].strip().lower() == 'true'
    if hidden or no_display or not name:
        return None
    filename = os.path.basename(path)
    icon_path = get_icon_path(icon) if icon else None
    return {
        'filename': filename,
        'name': name,
        'icon_name': icon,
        'icon_path': icon_path,
        'exec': f'gtk-launch {filename}'
    }
def main():
    base_dir = os.path.expanduser('~/.config/eww/start_menu')
    pinned_file = os.path.join(base_dir, 'pinned.json')
    
    # NEW: Load pinned filenames to check against
    try:
        with open(pinned_file, 'r') as f:
            pinned_filenames = json.load(f)
    except:
        pinned_filenames = []

    app_dirs = ['/usr/share/applications', os.path.expanduser('~/.local/share/applications')]
    apps = []
    seen = set()
    
    for d in app_dirs:
        if not os.path.isdir(d): continue
        for f in os.listdir(d):
            if not f.endswith('.desktop'): continue
            app = parse_desktop_file(os.path.join(d, f))
            if app:
                app['is_pinned'] = app['filename'] in pinned_filenames
                apps.append(app)

    apps.sort(key=lambda x: x['name'].lower())
    
    # Save cache and print for EWW
    cache_path = os.path.join(base_dir, 'all_apps.json')
    with open(cache_path, 'w') as f:
        json.dump(apps, f, indent=2)
    print(json.dumps(apps))
if __name__ == '__main__':
    main()