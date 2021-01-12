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
    --indicator \
    --timestr="%H:%M:%S" \
    --datestr="%d.%m.%Y" \
    --timecolor="${FG}ff" \
    --datecolor="${FG}ff" \
    --linecolor="${BG}ff" \
    --separatorcolor="${BG}ff" \
    --insidecolor="${BG}dd" \
    --insidewrongcolor="${BG}dd" \
    --wrongcolor="${FG}ff"
   #--verifcolor="${FG}ff" \
   #--ringcolor="${GRAY}ee" \
   #--keyhlcolor="${YELLOW}ff" \
   #--bshlcolor="${PURPLE}ff" \
   #--insidevercolor="${BG}dd"   \
   #--ringvercolor="${BLUE}ee" \
   #--ringwrongcolor="${RED}ee" \
