#!/bin/bash

# First check if LID is closed or not
lid_status=$(cat /proc/acpi/button/lid/LID/state | grep state | awk -F':' '{print $2}' |tr -d " ")

if [ "$lid_status" == "open" ]; then
    ~/.screenlayout/only_laptop.sh
else
    ~/.screenlayout/2_external_closed_lid.sh
fi
