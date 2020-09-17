#!/bin/bash

# First check if LID is closed or not
lid_status=$(cat /proc/acpi/button/lid/LID/state | grep state | awk -F':' '{print $2}' |tr -d " ")

if [ "$lid_status" == "open" ]; then
    # Now check if external displays are connected or not
    xrandr | grep -v disconnected | grep -v eDP1 | grep connected -q
    if [ $? -eq 0 ]; then
        /home/slaweq/.screenlayout/2_external_and_laptop.sh
    else
        /home/slaweq/.screenlayout/only_laptop.sh
    fi
else
    /home/slaweq/.screenlayout/2_external_closed_lid.sh
fi
