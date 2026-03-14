#!/bin/bash

DEVICE="amdgpu_bl1"
PATH_ACTUAL="/sys/class/backlight/$DEVICE/actual_brightness"
PATH_MAX="/sys/class/backlight/$DEVICE/max_brightness"

get_percent() {
    read -r curr < "$PATH_ACTUAL"
    read -r max < "$PATH_MAX"
    printf '%d\n' $(( curr * 100 / max ))
}

get_percent

udevadm monitor --subsystem-match=backlight --property |
while read -r line; do
    [[ $line == ACTION=change* ]] && get_percent
done