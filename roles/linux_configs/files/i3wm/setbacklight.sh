#!/bin/bash

action=$1
step=$2

current_level=$(/usr/bin/xbacklight -get | awk -F'.' '{print $1}')

if [ "$action" == "dec" ]; then
    new_level=$(( current_level - step ))
    if [ $new_level -le 10 ]; then
        new_level=10
    fi
else
    new_level=$(( current_level + step ))
    if [ $new_level -ge 100 ]; then
        new_level=100
    fi
fi

/usr/bin/xbacklight -set $new_level

/usr/bin/notify-send -a "Screen backlight" -u low -h string:x-canonical-private-synchronous:anything "[ $new_level% ]"
