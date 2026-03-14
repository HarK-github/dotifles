#!/bin/bash

# Commands to interact with our Python Daemon via DBus
case $1 in
dismiss)
	dbus-send --session --type=method_call --dest=org.freedesktop.Notifications \
		/org/freedesktop/Notifications org.freedesktop.Notifications.DismissPopup uint32:"$2"
	;;
close)
	dbus-send --session --type=method_call --dest=org.freedesktop.Notifications \
		/org/freedesktop/Notifications org.freedesktop.Notifications.CloseNotification uint32:"$2"
	;;
clear)
	dbus-send --session --type=method_call --dest=org.freedesktop.Notifications \
		/org/freedesktop/Notifications org.freedesktop.Notifications.ClearAll
	;;
*)
	# Return empty JSON for Eww
	echo '{"count": 0, "notifications": [], "popups": []}'
	;;
esac
