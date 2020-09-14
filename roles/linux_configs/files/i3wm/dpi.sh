#!/bin/bash

# First check if LID is closed or not
lid_status=$(cat /proc/acpi/button/lid/LID/state | grep state | awk -F':' '{print $2}' |tr -d " ")

if [ "$lid_status" == "open" ]; then
    sed -i -e 's/Xft.dpi:        144/Xft.dpi:        96/g' /home/slaweq/.Xresources
    xrandr --dpi 96
else
    sed -i -e 's/Xft.dpi:        96/Xft.dpi:        144/g' /home/slaweq/.Xresources
    old_dpi=96
    dpi=144
    xrandr --dpi 144
fi

xrdb ~/.Xresources
i3-msg restart
