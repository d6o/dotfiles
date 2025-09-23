#!/bin/bash

# This is the main logic script - not called directly by Raycast
monitor_index=$1

osascript <<EOF
use framework "AppKit"
use scripting additions

on getScreens()
    set screens to current application's NSScreen's screens()
    set screenList to {}
    repeat with screen in screens
        set frame to screen's frame()
        set originX to current application's NSMinX(frame)
        set originY to current application's NSMinY(frame)
        set width to current application's NSWidth(frame)
        set height to current application's NSHeight(frame)
        set end of screenList to {originX:originX, originY:originY, width:width, height:height}
    end repeat
    return screenList
end getScreens

set screens to getScreens()
if $monitor_index > (count of screens) then
    return "Monitor $monitor_index not available"
end if

set targetScreen to item $monitor_index of screens

tell application "System Events"
    set frontApp to name of first application process whose frontmost is true
end tell

tell application frontApp
    set currentWindow to front window
    set {originX, originY, width, height} to {originX, originY, width, height} of targetScreen
    
    -- Get current window size
    set currentBounds to bounds of currentWindow
    set windowWidth to (item 3 of currentBounds) - (item 1 of currentBounds)
    set windowHeight to (item 4 of currentBounds) - (item 2 of currentBounds)
    
    -- Center window on target monitor
    set newX to originX + (width - windowWidth) / 2
    set newY to originY + (height - windowHeight) / 2
    
    set bounds of currentWindow to {newX, newY, newX + windowWidth, newY + windowHeight}
end tell
EOF

