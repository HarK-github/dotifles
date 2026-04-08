#!/usr/bin/env python3
import os
import json

def main():
    base_dir = os.path.expanduser('~/.config/eww/start_menu')
    pinned_file = os.path.join(base_dir, 'pinned.json')
    all_apps_file = os.path.join(base_dir, 'all_apps.json')

    try:
        with open(pinned_file, 'r') as f:
            pinned_filenames = json.load(f)
        with open(all_apps_file, 'r') as f:
            all_apps = json.load(f)
    except:
        pinned_filenames, all_apps = [], []

    filename_to_app = {app['filename']: app for app in all_apps}
    pinned_list = [filename_to_app[f] for f in pinned_filenames if f in filename_to_app]

    # 1. Group apps into "Folders" of 4
    folders = [pinned_list[i:i + 4] for i in range(0, len(pinned_list), 4)]
    
    folder_grid = []
    for folder in folders:
        # 2. Group icons into 2x2 rows inside the folder
        rows = [folder[j:j + 2] for j in range(0, len(folder), 2)]
        folder_grid.append(rows)

    # 3. Group the FOLDERS themselves into rows of 4 for the main menu
    final_layout = [folder_grid[k:k + 4] for k in range(0, len(folder_grid), 4)]

    print(json.dumps(final_layout))

if __name__ == '__main__':
    main()