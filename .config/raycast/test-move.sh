#!/bin/bash
# @raycast.schemaVersion 1
# @raycast.title Test Move Window
# @raycast.mode fullOutput
# @raycast.packageName Window Management
# @raycast.icon 🧪

echo "Testing window movement..."

osascript <<EOF
tell application "System Events"
    set frontApp to name of first application process whose frontmost is true
    return "Current app: " & frontApp
end tell
EOF
