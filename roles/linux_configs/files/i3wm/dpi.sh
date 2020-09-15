#!/bin/bash

# First check if LID is closed or not
lid_status=$(cat /proc/acpi/button/lid/LID/state | grep state | awk -F':' '{print $2}' |tr -d " ")

if [ "$lid_status" == "open" ]; then
    # Now check if external displays are connected or not
    xrandr | grep -v disconnected | grep -v eDP1 | grep connected -q
    if [ $? -ne 0 ]; then
        sed -i -e 's/Xft.dpi:        144/Xft.dpi:        96/g' /home/slaweq/.Xresources
        xrandr --dpi 96
        xrdb ~/.Xresources
        i3-msg restart
        exit 0
    fi
fi

sed -i -e 's/Xft.dpi:        96/Xft.dpi:        144/g' /home/slaweq/.Xresources
xrandr --dpi 144
xrdb ~/.Xresources
i3-msg restart
