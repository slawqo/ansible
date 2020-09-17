#!/bin/sh

# Documentation at
# https://www.freedesktop.org/software/systemd/man/systemd-suspend.service.html

case $1 in
    post)
        /home/slaweq/.config/i3/screens.sh
    ;;
esac
