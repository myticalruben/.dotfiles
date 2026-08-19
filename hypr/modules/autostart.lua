-- Wallpaper shown at startup. Overridable per-machine from modules/local.lua
-- by setting the global `wallpaper`; resolved when the event fires, so the
-- override works regardless of module load order.
local default_wallpaper = os.getenv("HOME") .. "/Pictures/Wallpapers/01.png"

hl.on("hyprland.start", function()
    hl.exec_cmd("waybar")
    hl.exec_cmd("dunst")
    hl.exec_cmd("nm-applet")
    hl.exec_cmd("wl-paste --type text --watch cliphist store")
    hl.exec_cmd("wl-paste --type image --watch cliphist store")
    --hl.exec_cmd("/usr/lib/polkit-kde-authentication-agent-1")

    hl.exec_cmd("awww-daemon")
    hl.exec_cmd("sleep 1 && awww img '" .. (wallpaper or default_wallpaper) .. "'")
end)
