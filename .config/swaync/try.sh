#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

NOTIFY_FILE="$HOME/.cache/notifications.json"
SCRIPT_DIR="$HOME/.config/eww/scripts"

echo -e "${BLUE}════════════════════════════════════════════${NC}"
echo -e "${BLUE}   Notification Daemon Test Suite           ${NC}"
echo -e "${BLUE}════════════════════════════════════════════${NC}"

# Test 1: Check if daemon is running
echo -e "\n${YELLOW}🔍 Test 1: Checking if notification daemon is running...${NC}"
if pgrep -f "notifications.py" >/dev/null; then
	echo -e "${GREEN}✅ Daemon is running${NC}"
	DAEMON_PID=$(pgrep -f "notifications.py")
	echo "   PID: $DAEMON_PID"
else
	echo -e "${RED}❌ Daemon is NOT running${NC}"
	echo -e "   Start it with: ${BLUE}/usr/bin/python3 ~/.config/eww/scripts/notifications.py &${NC}"
fi

# Test 2: Check D-Bus registration
echo -e "\n${YELLOW}🔍 Test 2: Checking D-Bus registration...${NC}"
if dbus-send --session --dest=org.freedesktop.DBus \
	--type=method_call --print-reply \
	/org/freedesktop/DBus org.freedesktop.DBus.ListNames 2>/dev/null | grep -q "org.freedesktop.Notifications"; then
	echo -e "${GREEN}✅ Notification service is registered on D-Bus${NC}"
else
	echo -e "${RED}❌ Notification service NOT registered on D-Bus${NC}"
fi

# Test 3: Send basic notification
echo -e "\n${YELLOW}🔍 Test 3: Sending basic notification...${NC}"
notify-send "Test 1" "Basic notification test"
echo -e "${GREEN}✅ Sent: 'Test 1 - Basic notification test'${NC}"
sleep 1

# Test 4: Send notification with icon
echo -e "\n${YELLOW}🔍 Test 4: Sending notification with icon...${NC}"
notify-send -i info "Test 2" "Notification with info icon"
echo -e "${GREEN}✅ Sent: 'Test 2 - With info icon'${NC}"
sleep 1

# Test 5: Send urgent notification
echo -e "\n${YELLOW}🔍 Test 5: Sending urgent notification...${NC}"
notify-send -u critical "⚠️ URGENT" "This is a high priority notification!"
echo -e "${GREEN}✅ Sent: Urgent notification${NC}"
sleep 1

# Test 6: Send multi-line notification
echo -e "\n${YELLOW}🔍 Test 6: Sending multi-line notification...${NC}"
notify-send "Multi-line" "Line 1\nLine 2\nLine 3\nLine 4"
echo -e "${GREEN}✅ Sent: Multi-line notification${NC}"
sleep 1

# Test 7: Send multiple notifications in quick succession
echo -e "\n${YELLOW}🔍 Test 7: Stress test - 5 notifications in 2 seconds...${NC}"
for i in {1..5}; do
	notify-send "Stress Test $i" "Notification number $i"
	echo -n "."
	sleep 0.3
done
echo -e " ${GREEN}✅ Done${NC}"

# Test 8: Check JSON file
echo -e "\n${YELLOW}🔍 Test 8: Checking JSON file...${NC}"
if [ -f "$NOTIFY_FILE" ]; then
	echo -e "${GREEN}✅ JSON file exists: $NOTIFY_FILE${NC}"

	# Show file size
	SIZE=$(du -h "$NOTIFY_FILE" | cut -f1)
	echo "   File size: $SIZE"

	# Show notification count
	COUNT=$(jq -r '.count' "$NOTIFY_FILE" 2>/dev/null || echo "0")
	echo -e "   Notification count: ${BLUE}$COUNT${NC}"

	# Show last 3 notifications
	echo -e "\n${BLUE}   Last 3 notifications:${NC}"
	jq -r '.notifications[:3] | .[] | "   [\(.id)] \(.app): \(.summary)"' "$NOTIFY_FILE" 2>/dev/null || echo "   No notifications found"
else
	echo -e "${RED}❌ JSON file NOT found!${NC}"
fi

# Test 9: Test DND toggle
echo -e "\n${YELLOW}🔍 Test 9: Testing DND toggle...${NC}"

# Get current DND state
CURRENT_DND=$("$SCRIPT_DIR/notifications.sh" dnd-status 2>/dev/null || echo "false")
echo -e "   Current DND state: ${BLUE}$CURRENT_DND${NC}"

# Toggle DND
echo -e "   Toggling DND..."
"$SCRIPT_DIR/notifications.sh" toggle-dnd

# Get new DND state
NEW_DND=$("$SCRIPT_DIR/notifications.sh" dnd-status 2>/dev/null || echo "false")
echo -e "   New DND state: ${BLUE}$NEW_DND${NC}"

if [ "$CURRENT_DND" != "$NEW_DND" ]; then
	echo -e "${GREEN}   ✅ DND toggle successful${NC}"
else
	echo -e "${RED}   ❌ DND toggle failed${NC}"
fi

# Test 10: Send notification in DND mode (if DND is on)
if [ "$NEW_DND" = "true" ]; then
	echo -e "\n${YELLOW}🔍 Test 10: Testing notification in DND mode...${NC}"
	notify-send "DND Test" "This should NOT create a popup"
	echo -e "${GREEN}✅ Sent notification while DND is ON${NC}"
	sleep 1

	# Toggle DND back off
	echo -e "   Turning DND off..."
	"$SCRIPT_DIR/notifications.sh" toggle-dnd
fi

# Test 11: Test close notification
echo -e "\n${YELLOW}🔍 Test 11: Testing close notification...${NC}"
notify-send "Close Test" "This will be closed in 2 seconds"
sleep 1

# Get the latest notification ID
if [ -f "$NOTIFY_FILE" ]; then
	LATEST_ID=$(jq -r '.notifications[0].id' "$NOTIFY_FILE" 2>/dev/null)
	if [ "$LATEST_ID" != "null" ] && [ -n "$LATEST_ID" ]; then
		echo -e "   Latest notification ID: ${BLUE}$LATEST_ID${NC}"
		echo -e "   Closing notification $LATEST_ID..."
		"$SCRIPT_DIR/notifications.sh" close "$LATEST_ID"
		echo -e "${GREEN}✅ Close command sent${NC}"
	else
		echo -e "${RED}❌ Could not get notification ID${NC}"
	fi
fi

# Test 12: Test clear all
echo -e "\n${YELLOW}🔍 Test 12: Testing clear all...${NC}"
"$SCRIPT_DIR/notifications.sh" clear
echo -e "${GREEN}✅ Clear all command sent${NC}"
sleep 1

# Final JSON check
echo -e "\n${YELLOW}🔍 Final JSON check after clearing:${NC}"
if [ -f "$NOTIFY_FILE" ]; then
	FINAL_COUNT=$(jq -r '.count' "$NOTIFY_FILE" 2>/dev/null)
	echo -e "   Notification count after clear: ${BLUE}$FINAL_COUNT${NC}"
	if [ "$FINAL_COUNT" = "0" ]; then
		echo -e "${GREEN}   ✅ Clear all successful${NC}"
	else
		echo -e "${RED}   ❌ Clear all failed - count is $FINAL_COUNT${NC}"
	fi
fi

# Test 13: Test script commands
echo -e "\n${YELLOW}🔍 Test 13: Testing notification script commands...${NC}"

echo -e "   Running: ${BLUE}notifications.sh current${NC} (head -3)"
"$SCRIPT_DIR/notifications.sh" current 2>/dev/null | head -3

echo -e "\n   Running: ${BLUE}notifications.sh count${NC}"
COUNT=$("$SCRIPT_DIR/notifications.sh" count 2>/dev/null)
echo -e "   Result: ${BLUE}$COUNT${NC}"

echo -e "\n   Running: ${BLUE}notifications.sh dnd-status${NC}"
DND=$("$SCRIPT_DIR/notifications.sh" dnd-status 2>/dev/null)
echo -e "   Result: ${BLUE}$DND${NC}"

# Test 14: Check for competing daemons
echo -e "\n${YELLOW}🔍 Test 14: Checking for competing notification daemons...${NC}"
COMPETING=$(ps aux | grep -E "notification-daemon|gnome-shell|mako|dunst|swaync" | grep -v grep | grep -v notifications.py)
if [ -n "$COMPETING" ]; then
	echo -e "${RED}❌ Found competing daemons:${NC}"
	echo "$COMPETING" | while read line; do
		echo "   $line"
	done
	echo -e "${YELLOW}   Consider stopping them with: pkill -f <daemon-name>${NC}"
else
	echo -e "${GREEN}✅ No competing daemons found${NC}"
fi

# Summary
echo -e "\n${BLUE}════════════════════════════════════════════${NC}"
