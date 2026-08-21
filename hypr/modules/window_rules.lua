-- La opacidad la elige scripts/opacity.sh, que la guarda aqui. El archivo esta
-- FUERA del repositorio a proposito: antes el script hacia sed -i sobre este
-- mismo archivo, y como ~/.config/hypr es un symlink al checkout, cambiar la
-- opacidad dejaba el arbol de git sucio. Peor con la variante `.#vm` de
-- home-manager, donde este archivo es una ruta de /nix/store de solo lectura y
-- el sed fallaba sin mas.
local default_opacity = 0.7

local function saved_opacity()
	local state = os.getenv("XDG_STATE_HOME") or (os.getenv("HOME") .. "/.local/state")
	local f = io.open(state .. "/hypr/opacity", "r")
	if not f then return nil end

	local value = tonumber(f:read("*l"))
	f:close()

	-- Un archivo corrupto o a medio escribir no debe dejar las ventanas
	-- invisibles: fuera de rango se ignora y manda el valor por defecto.
	if value and value > 0 and value <= 1 then return value end
	return nil
end

local window_opacity = saved_opacity() or default_opacity

-- Layer rules (old: layerrule = blur on / ignore_alpha 0.15, match:namespace rofi)
hl.layer_rule({
    match = { namespace = "rofi" },
    blur = true,
    ignore_alpha = 0.15,
})

-- Opacity rule for your regular apps
hl.window_rule({
    name = "opacity-apps",
    match = {
        class = "^(kitty|xed|thunar|discord|codium|GeForceNOW|obsidian|Spotify|org.pulseaudio.pavucontrol|com.github.johnfactotum.Foliate)$",
    },
    opacity = window_opacity .. " override " .. window_opacity .. " override 1.0 override",
})

-- Float rules (fixed: unique names + float = true actually set)
hl.window_rule({
    name = "float-pavucontrol",
    match = { class = "^(pavucontrol)$" },
    float = true,
})

hl.window_rule({
    name = "float-nm-connection-editor",
    match = { class = "^(nm-connection-editor)$" },
    float = true,
})

hl.window_rule({
    name = "float-blueman-manager",
    match = { class = "^(blueman-manager)$" },
    float = true,
})

hl.window_rule({
    name = "float-open-file",
    match = { title = "^(Open File)$" },
    float = true,
})

hl.window_rule({
    name = "float-save-file",
    match = { title = "^(Save File)$" },
    float = true,
})
