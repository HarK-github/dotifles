#!/bin/bash

# 1. Kill any existing instances to prevent conflicts
pkill eww
pkill end-rs

# 2. Start the eww daemon first
eww daemon &

# 3. Give the daemon a half-second to initialize
sleep 0.5

# 4. Open your specific eww windows
eww open bar
eww open notification-frame &

# 5. Launch the notification daemon (end-rs)
# We add a tiny delay to ensure it doesn't fight with Eww
sleep 1
/home/harshit-kandpal/.cargo/bin/end-rs daemon > /home/harshit-kandpal/.end-rs.log 2>&1 &