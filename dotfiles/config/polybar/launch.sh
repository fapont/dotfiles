# Env variables for polybar style
export polybar_height=2%
export polybar_radius=6
export polybar_monitor=eDP-1

# Env variable for polybar widgets
export NETWORK_INTERFACE=$(ip route | grep '^default' | awk '{print $5}' | head -n1)
export BATTERY='BAT0'

# Env variable for scripts
export UPDATES_SCRIPT=/home/fapont/.config/scripts/updates


# Launch polybar

killall -q polybar
polybar -q topLeft1 &
polybar -q topLeft1 &
polybar -q topLeft2 &
polybar -q middle &
polybar -q topright1 &
polybar -q topright2 &