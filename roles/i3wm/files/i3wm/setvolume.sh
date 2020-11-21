#!/bin/bash

action=$1
step=$2

if [ "$action" == "mute" ]; then
    pamixer --toggle-mute
else
    if [ "$action" == "inc" ]; then
        pamixer --increase $step
    else
        pamixer --decrease $step
    fi
fi
new_level=$(pamixer --get-volume-human)

/usr/bin/notify-send -a "Volume" -u low -h string:x-canonical-private-synchronous:anything "[ $new_level ]"
