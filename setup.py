#!/usr/bin/env python3
"""Link every config in this repo into ~/.config (and ~/.local/bin).

Safe to re-run: entries already linked are reported and left alone, and nothing
is ever deleted. Pass --force to repoint symlinks that aim somewhere else.
"""

import sys

from utils import ccf, summary, Type

print("Setting up Hyprland Dotfiles")
print()

ccf("rofi", Type.FOLDER)
ccf("nvim", Type.FOLDER)
ccf("dunst", Type.FOLDER)
ccf("hypr", Type.FOLDER)
ccf("waybar", Type.FOLDER)
ccf("wlogout", Type.FOLDER)
ccf("btop", Type.FOLDER)
ccf("quickshell", Type.FOLDER)
ccf("scripts/volume", Type.BIN)

code = summary()

print()
print("Machine-specific settings (monitors, wallpaper) go in")
print("  hypr/modules/local.lua   - copy it from hypr/modules/local.lua.example")
print("It is gitignored, so it stays out of the shared config.")

sys.exit(code)
