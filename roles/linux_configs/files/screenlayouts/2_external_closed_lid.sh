#!/bin/sh
xrandr --output eDP1 --off --output DP1 --off --output DP3 --off --output DP3-1 --off --output DP3-2 --off --output DP3-3 --mode 3840x2160 --pos 0x0 --rotate normal --output DP2 --primary --mode 3840x2160 --pos 3840x0 --rotate normal --output VIRTUAL1 --off
if [ $? -ne 0 ]; then
    xrandr --output eDP1 --off --output DP1 --off --output DP2 --off --output DP2-1 --off --output DP2-2 --off --output DP2-3 --mode 3840x2160 --pos 0x0 --rotate normal --output DP3 --primary --mode 3840x2160 --pos 3840x0 --rotate normal --output VIRTUAL1 --off
fi
