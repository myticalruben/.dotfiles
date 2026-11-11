-- Fallback wallpaper, used only until one is picked in the selector (MOD+W):
-- from then on `wallpaper restore` puts back whatever was chosen last, which
-- is what it reads from ~/.local/state/hypr/wallpaper. Overridable per-machine
-- from modules/local.lua by setting the global `wallpaper`; resolved when the
-- event fires, so the override works regardless of module load order.
local default_wallpaper = os.getenv("HOME") .. "/Pictures/Wallpapers/01.png"

hl.on("hyprland.start", function()
	-- Un solo proceso ordena el arranque: el fondo hace un fade suave y
	-- después aparecen waybar, dunst y el resto. Sin splash ni logo.
	hl.exec_cmd("session-start '" .. (wallpaper or default_wallpaper) .. "'")
end)
