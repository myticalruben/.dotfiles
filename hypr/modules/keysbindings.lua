local home = os.getenv("HOME")


-- Locales, no globales: solo los usa este archivo, y dejarlos sueltos en el
-- entorno global de la config es pedirle a otro modulo que los pise sin querer.
local mod         = "SUPER"
local terminal    = "kitty"
local fileManager = "thunar"
local hyprshot    = "hyprshot -m region"
local menu        = "rofi -show drun"
-- The apt package installs "brave-browser", the AUR one installs "brave", so
-- neither name is portable. Pick the first that actually exists on this box.
--
-- This walks $PATH instead of shelling out: Hyprland reaps its own children,
-- so os.execute always returns nil/"No child processes" inside the config and
-- cannot be used to probe for a command.
local function first_available(...)
	local candidates = { ... }
	for _, cmd in ipairs(candidates) do
		for dir in (os.getenv("PATH") or ""):gmatch("[^:]+") do
			local f = io.open(dir .. "/" .. cmd, "r")
			if f then
				f:close()
				return cmd
			end
		end
	end
	return candidates[1]
end

local browser = first_available("brave", "brave-browser", "firefox")

hl.bind(mod .. " + return"              , hl.dsp.exec_cmd(terminal))
hl.bind(mod .. " + o"                   , hl.dsp.exec_cmd(hyprshot))
hl.bind(mod .. " + E"                   , hl.dsp.exec_cmd(fileManager))
hl.bind(mod .. " + Tab"					, hl.dsp.exec_cmd("hyprlock"))
hl.bind(mod .. " + GRAVE"				, hl.dsp.exec_cmd("wlogout -b 5 -c 20 -r 20 -n"))
hl.bind(mod .. " + W", hl.dsp.exec_cmd("quickshell -c hyprquickpaper"))

-- Ruta via XDG, no "~/.dotfiles": el checkout no tiene por que estar ahi.
hl.bind(mod .. " + SHIFT + O", hl.dsp.exec_cmd(
    (os.getenv("XDG_CONFIG_HOME") or (home .. "/.config")) .. "/hypr/scripts/opacity.sh"))


-- Toggle waybar
hl.bind(mod .. " + SHIFT + W"			, hl.dsp.exec_cmd("sh -c 'pkill waybar || nohup waybar >/dev/null 2>&1 &'"))

-- Screenshots
hl.bind(mod .. " + Print"				, hl.dsp.exec_cmd("grim " .. home .. "/Pictures/$(date +%s).png"))
hl.bind("Print"							, hl.dsp.exec_cmd('grim -g "$(slurp)" ' .. home .. '/Pictures/$(date +%s).png'))

-- Clipboard
hl.bind(mod .. " + V", hl.dsp.exec_cmd(
    "cliphist list | rofi -dmenu -p '' | cliphist decode | wl-copy"
))


-- Apagar y reiniciar NO estan aqui a proposito: SUPER+Q cierra la ventana, y
-- tener el apagado en SUPER+SHIFT+Q significaba que un SHIFT de mas te apagaba
-- el equipo sin preguntar. Los dos estan en wlogout (SUPER + `), que ademas
-- pasa por systemctl y respeta polkit y los inhibidores.
hl.bind(mod .. " + CONTROL + s"         , hl.dsp.exec_cmd("systemctl suspend"))
hl.bind(mod .. " + SHIFT + m"           , hl.dsp.exit())


hl.bind(mod .. " + D"                   , hl.dsp.exec_cmd(menu))
hl.bind(mod .. " + B"                   , hl.dsp.exec_cmd(browser))

hl.bind(mod .. " + S"                   , hl.dsp.workspace.toggle_special("magic"))
hl.bind(mod .. " + SHIFT + S"           , hl.dsp.window.move({ workspace = "special:magic" }))

hl.bind(mod .. " + mouse_up"            , hl.dsp.focus({ workspace = "e-1" }))
hl.bind(mod .. " + mouse_down"          , hl.dsp.focus({ workspace = "e+1" }))

hl.bind(mod .. " + mouse:272"           , hl.dsp.window.drag(), { mouse = true })
hl.bind(mod .. " + mouse:273"           , hl.dsp.window.resize(), { mouse = true })


hl.bind(mod .. " + q"                   , hl.dsp.window.close())
hl.bind(mod .. " + F"                   , hl.dsp.window.fullscreen({mode = 0 }))
hl.bind(mod .. " + SHIFT + t"           , hl.dsp.window.float({action = "toggle"}))


hl.bind(mod .. " + h"                   , hl.dsp.focus({ direction = "left" }))
hl.bind(mod .. " + l"                   , hl.dsp.focus({ direction = "right" }))
hl.bind(mod .. " + k"                   , hl.dsp.focus({ direction = "up" }))
hl.bind(mod .. " + j"                   , hl.dsp.focus({ direction = "down" }))


hl.bind(mod .. " + SHIFT + H"			, hl.dsp.window.move({ direction = "left" }))
hl.bind(mod .. " + SHIFT + J"			, hl.dsp.window.move({ direction = "down" }))
hl.bind(mod .. " + SHIFT + K"			, hl.dsp.window.move({ direction = "up" }))
hl.bind(mod .. " + SHIFT + L"			, hl.dsp.window.move({ direction = "right" }))

hl.bind(mod .. " + CTRL + H", hl.dsp.window.resize({ x = -10, y = 0, relative = true }), { repeating = true })
hl.bind(mod .. " + CTRL + L", hl.dsp.window.resize({ x = 10, y = 0, relative = true }), { repeating = true })
hl.bind(mod .. " + CTRL + K", hl.dsp.window.resize({ x = 0, y = -10, relative = true }), { repeating = true })
hl.bind(mod .. " + CTRL + J", hl.dsp.window.resize({ x = 0, y = 10, relative = true }), { repeating = true })


-- Via scripts/volume (enlazado en ~/.local/bin) en vez de wpctl directo: hace
-- lo mismo y ademas ensena la notificacion con barra, que es la unica forma
-- de saber donde esta el volumen sin abrir pavucontrol.
hl.bind("XF86AudioRaiseVolume"          , hl.dsp.exec_cmd("volume up"),                                      { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume"          , hl.dsp.exec_cmd("volume down"),                                    { locked = true, repeating = true })
hl.bind("XF86AudioMute"                 , hl.dsp.exec_cmd("volume mute"),                                    { locked = true, repeating = true })
hl.bind("XF86AudioMicMute"              , hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),   { locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp"           , hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"),                  { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown"         , hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"),                  { locked = true, repeating = true })

hl.bind("XF86AudioNext"                 , hl.dsp.exec_cmd("playerctl next"),       { locked = true })
hl.bind("XF86AudioPrev"                 , hl.dsp.exec_cmd("playerctl previous"),   { locked = true })
hl.bind("XF86AudioPause"                , hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay"                 , hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })

-- Toggle window Center and rezise
hl.bind(mod .. " + Space", function()
    hl.dispatch(hl.dsp.window.float({ action = "toggle" }))

    local w = hl.get_active_window()
    if w ~= nil and w.floating then
        local mon = hl.get_active_monitor()
        if mon ~= nil then
            local target_w = math.floor(mon.width * 0.7)
            local target_h = math.floor(mon.height * 0.7)

            -- absolute resize (relative = false), not a delta
            hl.dispatch(hl.dsp.window.resize({ x = target_w, y = target_h, relative = false }))

            local mon_x = mon.x or 0
            local mon_y = mon.y or 0
            local target_x = mon_x + math.floor((mon.width - target_w) / 2)
            local target_y = mon_y + math.floor((mon.height - target_h) / 2)

            -- absolute move to the centered position
            hl.dispatch(hl.dsp.window.move({ x = target_x, y = target_y, relative = false }))
        end
    end
end)

for i = 1, 10 do
	local key = i % 10
	hl.bind(mod .. " + "          .. key  , hl.dsp.focus({ workspace = i }))
	hl.bind(mod .. " + SHIFT + "  .. key  , hl.dsp.window.move({ workspace = i }))
end
