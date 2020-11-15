#!/bin/bash

action=$1
step=$2

if [ "$action" == "mute" ]; then
    amixer -q sset Master,0 toggle
    current_state=$(amixer -D pulse sget Master | grep 'Mono:' | awk -F'[][]' '{ print $2" "$4 }')
    mute_state=$(echo $current_state | awk '{ print $2}')
    if [ "$mute_state" == "off" ]; then
        new_level=0%
    else
        new_level=$(echo $current_state | awk '{print $1 }')
    fi
else
    if [ "$action" == "inc" ]; then
        amixer -q sset Master,0 $step%+ unmute
    else
        amixer -q sset Master,0 $step%- unmute
    fi
    new_level=$(amixer sget Master | grep 'Mono:' | awk -F'[][]' '{ print $2 }')
fi

/usr/bin/notify-send -a "Volume" -u low -h string:x-canonical-private-synchronous:anything "[ $new_level ]"
