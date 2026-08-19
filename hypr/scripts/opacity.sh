#!/bin/bash

choice=$(printf "100%%\n90%%\n80%%\n70%%\n60%%\n50%%\n40%%" | rofi -dmenu -p "")

case "$choice" in
    "100%") opacity=1.0 ;;
    "90%")  opacity=0.9 ;;
    "80%")  opacity=0.8 ;;
    "70%")  opacity=0.7 ;;
    "60%")  opacity=0.6 ;;
    "50%")  opacity=0.5 ;;
    "40%")  opacity=0.4 ;;
    *) exit 0 ;;
esac

# The value lives in modules/window_rules.lua (this used to point at a
# rules.lua that does not exist, so the script silently did nothing).
config_dir="${XDG_CONFIG_HOME:-$HOME/.config}/hypr"
sed -i "s/^local window_opacity = .*/local window_opacity = $opacity/" "$config_dir/modules/window_rules.lua"

hyprctl reload