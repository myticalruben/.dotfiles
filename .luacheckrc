-- Config de luacheck para el CI.

std = "min"

files["hypr/"] = {
	-- `hl` lo inyecta Hyprland en la config; `wallpaper` lo define
	-- modules/local.lua (no versionado) y lo lee modules/autostart.lua.
	globals = { "wallpaper" },
	read_globals = { "hl" },
}

-- No está versionado (lo crea cada máquina a partir de local.lua.example), así
-- que en CI no existe. Excluirlo hace que una ejecución local diga lo mismo
-- que la del CI en vez de dar avisos que nadie puede arreglar en el repo.
exclude_files = { "hypr/modules/local.lua" }

-- Las tablas de config son largas a propósito; cortarlas a 80 columnas las
-- haría menos legibles, no más.
max_line_length = false
