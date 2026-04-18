from utils import ccf, Type

print("Setting up Hyprland Dotfiles")


ccf("rofi", Type.FOLDER)
print()
ccf("dunst", Type.FOLDER)
print()
ccf("hypr", Type.FOLDER)
print
ccf("scripts/volume", Type.BIN)
