-- Fallback wallpaper, used only until one is picked in the selector (MOD+W):
-- from then on `wallpaper restore` puts back whatever was chosen last, which
-- is what it reads from ~/.local/state/hypr/wallpaper. Overridable per-machine
-- from modules/local.lua by setting the global `wallpaper`; resolved when the
-- event fires, so the override works regardless of module load order.
local default_wallpaper = os.getenv("HOME") .. "/Pictures/Wallpapers/01.png"

hl.on("hyprland.start", function()
	-- hl.exec_cmd("waybar")
	hl.exec_cmd("dunst")
	hl.exec_cmd("nm-applet")
	hl.exec_cmd("wl-paste --type text --watch cliphist store")
	hl.exec_cmd("wl-paste --type image --watch cliphist store")
	--hl.exec_cmd("/usr/lib/polkit-kde-authentication-agent-1")

	hl.exec_cmd("awww-daemon")
	-- No sleep here: the script waits for the daemon to answer before asking
	-- it for anything.
	hl.exec_cmd("wallpaper restore '" .. (wallpaper or default_wallpaper) .. "'")
end)
