#!/usr/bin/env bash

# Add this script to your wm startup file.

DIR="$HOME/.config/polybar"

# Terminate already running bar instances
killall -q polybar

# Wait until the processes have been shut down
while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done

# Launch the bar

polybar -q pam1 -c "$DIR"/config.ini &
polybar -q pam2 -c "$DIR"/config.ini &
polybar -q pam3 -c "$DIR"/config.ini &
polybar -q pam4 -c "$DIR"/config.ini &
polybar -q pam5 -c "$DIR"/config.ini &
polybar -q pam6 -c "$DIR"/config.ini &
