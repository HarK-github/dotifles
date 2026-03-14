#!/bin/bash

get_status() {
    # Check if Bluetooth is powered on
    if ! bluetoothctl show | grep -q "Powered: yes"; then
        echo '{"enabled": false, "connected": false, "device": "Off"}'
        return
    fi

    # Find the connected device name
    # Using 'bluetoothctl devices' directly to find the connected one
    CONNECTED_DEVICE=$(bluetoothctl devices | while read -r line; do
        mac=$(echo "$line" | cut -d ' ' -f 2)
        name=$(echo "$line" | cut -d ' ' -f 3-)
        # Check info for this specific MAC
        if bluetoothctl info "$mac" 2>/dev/null | grep -q "Connected: yes"; then
            echo "$name"
            break
        fi
    done)

    if [ -n "$CONNECTED_DEVICE" ]; then
        echo "{\"enabled\": true, \"connected\": true, \"device\": \"$CONNECTED_DEVICE\"}"
    else
        echo '{"enabled": true, "connected": false, "device": "On"}'
    fi
}

# 1. Immediate initial output
get_status

# 2. Listen for signals from the BlueZ service
# This watches for property changes (Power, Connection, etc.)
dbus-monitor --system "type='signal',sender='org.bluez'" 2>/dev/null | stdbuf -oL grep --line-buffered "PropertiesChanged" | while read -r line; do
    get_status
done | stdbuf -oL uniq