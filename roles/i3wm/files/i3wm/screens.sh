#!/bin/bash

logger "Start display configuration script"
sleep_time=$1

if [ -z "$sleep_time" ]; then
    sleep_time=0
fi

logger "Display configuration delayed by $sleep_time seconds"
sleep $sleep_time

# Check if external displays are connected or not
xrandr | grep -v disconnected | grep -v eDP | grep connected -q
if [ $? -eq 0 ]; then
    logger "Configuring 3 external monitors"
    /home/slaweq/.screenlayout/3_external_monitors.sh
else
    logger "Configuring only laptop display"
    /home/slaweq/.screenlayout/only_laptop.sh
fi

# and also set correct Xserver settings
xset r rate 200 25
xset b off

# Set wallpaper
/home/slaweq/.fehbg

logger "Display configuration script finished"
