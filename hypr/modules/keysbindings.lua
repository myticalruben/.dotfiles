local mod           = "SUPER"
local terminal      = "kitty"
local fileManager   = "thunar"
local hyprshot      = "hyprshot -m region"
local menu          = "rofi -show drun -show-icons -theme launchpad"

hl.bind(mod .. " + q"                   , hl.dsp.window.close())
hl.bind(mod .. " + return"              , hl.dsp.exec_cmd(terminal))
hl.bind(mod .. " + SHIFT + q"           , hl.dsp.exec_cmd("command shutdown now"))
hl.bind(mod .. " + SHIFT + m"           , hl.dsp.exec_cmd(" command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch exit"))

hl.bind(mod .. " + space"               , hl.dsp.exec_cmd(menu))

hl.bind(mod .. " + S"                   , hl.dsp.workspace.toggle_special("magic"))
hl.bind(mod .. " + SHIFT + S"           , hl.dsp.window.move({ workspace = "special:magic" }))

hl.bind(mod .. " + mouse_up"            , hl.dsp.focus({ workspace = "e-1" }))
hl.bind(mod .. " + mouse_down"          , hl.dsp.focus({ workspace = "e+1" }))

hl.bind(mod .. " + mouse:272"           , hl.dsp.window.drag(), { mouse = true })
hl.bind(mod .. " + mouse:273"           , hl.dsp.window.resize(), { mouse = true })

hl.bind("XF86AudioRaiseVolume"          , hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume"          , hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),      { locked = true, repeating = true })
hl.bind("XF86AudioMute"                 , hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),     { locked = true, repeating = true })
hl.bind("XF86AudioMicMute"              , hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),   { locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp"           , hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"),                  { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown"         , hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"),                  { locked = true, repeating = true })

hl.bind("XF86AudioNext"                 , hl.dsp.exec_cmd("playerctl next"),       { locked = true })
hl.bind("XF86AudioPrev"                 , hl.dsp.exec_cmd("playerctl previous"),   { locked = true })
hl.bind("XF86AudioPause"                , hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay"                 , hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })

for i = 1, 9 do
	local key = i % 9
	hl.bind(mod .. " + "          .. key  , hl.dsp.focus({ workspace = i }))
	hl.bind(mod .. " + SHIFT + "  .. key  , hl.dsp.window.move({ workspace = i }))
end
