#!/bin/sh
#
BG='#282828'
RED='#fb4934'
GREEN='#b8bb26'
GRAY='#444444'
BLUE='#00aaff'
PURPLE='#d3869b'
YELLOW='#ffb700'
FG='#f08379'


#
# Launch i3lock-color
#
i3lock \
    --color='282828' \
    --show-failed-attempts \
    --ignore-empty-password \
    --pass-media-keys \
    --pass-screen-keys \
    --pass-power-keys \
    --blur 5 \
    --radius 110 \
    --ring-width 10 \
    --clock \
    --indicator
