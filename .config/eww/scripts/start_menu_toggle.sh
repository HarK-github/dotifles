#!/bin/bash
STATE=$(eww get start_menu_open)
if [ "$STATE" = "true" ]; then
    eww update start_menu_open=false
else
    eww update start_menu_open=true
fi