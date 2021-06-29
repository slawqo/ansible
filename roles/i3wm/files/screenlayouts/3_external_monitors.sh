#!/bin/sh
xrandr --output DP3-1 --mode 1920x1080 --pos 0x0 --rotate normal
xrandr --output DP3-2 --mode 1920x1080 --pos 3840x0 --rotate normal
xrandr --output DP3-3 --primary --mode 1920x1080 --pos 1920x0 --rotate normal
xrandr --output eDP1 --off
xrandr --output DP1 --off
xrandr --output DP2 --off
xrandr --output DP3 --off
xrandr --output VIRTUAL1 --off
