#!/bin/bash

# First check if LID is closed or not
lid_status=$(cat /proc/acpi/button/lid/LID/state | grep state | awk -F':' '{print $2}' |tr -d " ")

if [ "$lid_status" == "open" ]; then
    # Now check if external displays are connected or not
    xrandr | grep -v disconnected | grep -v eDP | grep connected -q
    if [ $? -eq 0 ]; then
        /home/slaweq/.screenlayout/3_external_monitors.sh
    else
        /home/slaweq/.screenlayout/only_laptop.sh
    fi
else
    /home/slaweq/.screenlayout/3_external_monitors.sh
fi

# and also set correct Xserver settings
xset r rate 200 25
xset b off

# Set wallpaper
/home/slaweq/.fehbg
