#!/bin/bash

# Toggle the power in the background so EWW doesn't timeout
if bluetoothctl show | grep -q "Powered: yes"; then
    bluetoothctl power off &
else
    bluetoothctl power on &
fi

# Exit immediately with success so EWW is happy
exit 0