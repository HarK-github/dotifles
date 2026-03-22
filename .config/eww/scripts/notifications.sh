#!/bin/bash

case $1 in
    togglednd)
        # Toggle the Eww variable
        CURRENT_STATE=$(eww get do-not-disturb)
        if [ "$CURRENT_STATE" == "false" ]; then
            eww update do-not-disturb=true
        else
            eww update do-not-disturb=false
        fi
        ;;
    close)
        # Tell end-rs to close a specific notification
        # $2 is the notification ID passed from the widget
        end-rs close "$2"
        ;;
    clear)
        # Tell end-rs to clear all notifications
        end-rs clear
        ;;
    action)
        # Trigger a notification action (button click)
        # $2 is ID, $3 is Action Key
        end-rs action "$2" "$3"
        ;;
esac
