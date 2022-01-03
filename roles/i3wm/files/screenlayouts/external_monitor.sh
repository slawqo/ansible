#!/bin/sh
xrandr --output eDP1 --off
xrandr --output DP1 --off
xrandr --output DP2 --off
xrandr --output DP3 --off
xrandr --output DP3-3 --primary --mode 5120x1440 --rotate normal
xrandr --output VIRTUAL1 --off
