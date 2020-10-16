#!/bin/sh
xrandr --output eDP1 --off --output DP1 --off --output DP2 --off --output DP2-1 --off --output DP2-2 --off --output DP2-3 --primary --mode 1920x1080 --pos 0x0 --rotate normal --output DP3 --mode 1920x1080 --pos 1920x0 --rotate normal --output VIRTUAL1 --off 2>/dev/null
if [ $? -ne 0 ]; then
    xrandr --output eDP1 --off --output DP1 --off --output DP3 --off --output DP3-1 --off --output DP3-2 --off --output DP3-3 --primary --mode 1920x1080 --pos 0x0 --rotate normal --output DP2 --mode 1920x1080 --pos 1920x0 --rotate normal --output VIRTUAL1 --off 2>/dev/null
fi
