#!/bin/bash
# Toggle built-in camera on/off
# Tries multiple methods: v4l2-ctl controls, then pkexec modprobe

CAM_MODULE="uvcvideo"

# Method 1: v4l2-ctl with streaming control (no root needed)
for dev in /dev/video*; do
    [ -c "$dev" ] || continue
    if v4l2-ctl -d "$dev" --get-ctrl=streaming_control &>/dev/null; then
        STATE=$(v4l2-ctl -d "$dev" --get-ctrl=streaming_control 2>/dev/null | cut -d: -f2 | tr -d ' ')
        if [ "$STATE" = "0" ] || [ "$STATE" = "0x0" ]; then
            v4l2-ctl -d "$dev" --set-ctrl=streaming_control=1 &>/dev/null
            notify-send "Camera toggle" "ON"
        else
            v4l2-ctl -d "$dev" --set-ctrl=streaming_control=0 &>/dev/null
            notify-send "Camera toggle" "OFF"
        fi
        exit 0
    fi
done

# Method 2: modprobe via pkexec (graphical password prompt)
if lsmod | grep -q "^$CAM_MODULE "; then
    if pkexec modprobe -r "$CAM_MODULE" 2>/dev/null; then
        notify-send "Camera toggle" "OFF"
    else
        notify-send "Camera toggle" "Failed - camera may be in use"
    fi
else
    if pkexec modprobe "$CAM_MODULE" 2>/dev/null; then
        notify-send "Camera toggle" "ON"
    else
        notify-send "Camera toggle" "No camera detected"
    fi
fi
