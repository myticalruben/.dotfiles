#!/usr/bin/env bash
#
# Elige la opacidad de las ventanas desde un menú de rofi.
#
# Antes esto hacía `sed -i` sobre modules/window_rules.lua. Como ~/.config/hypr
# es un symlink al checkout, cada cambio de opacidad ensuciaba el árbol de git;
# y con la variante `.#vm` de home-manager ese archivo es una ruta de
# /nix/store de solo lectura, así que ahí fallaba directamente.
#
# Ahora el valor va a un archivo de estado fuera del repositorio: la sesión en
# marcha se actualiza al momento, y window_rules.lua lo lee al arrancar, de
# modo que la elección sigue sobreviviendo a un reinicio.

set -euo pipefail

config_dir="${XDG_CONFIG_HOME:-$HOME/.config}/hypr"
state_file="${XDG_STATE_HOME:-$HOME/.local/state}/hypr/opacity"
rules="$config_dir/modules/window_rules.lua"

choice=$(printf '100%%\n90%%\n80%%\n70%%\n60%%\n50%%\n40%%\n' | rofi -dmenu -p "")
[[ -n "${choice:-}" ]] || exit 0

opacity="0.${choice%\%}"
[[ "$choice" == "100%" ]] && opacity="1.0"

# La lista de clases vive en window_rules.lua y se lee de ahí, no se repite
# aquí: si se añade una app a la regla, este script la recoge sola. Leer basta,
# así que funciona igual cuando el archivo es de solo lectura.
class=$(sed -n 's/^[[:space:]]*class = "\(.*\)",$/\1/p' "$rules" | head -n1)
if [[ -z "$class" ]]; then
    echo "No se encontró la lista de clases en $rules" >&2
    exit 1
fi

mkdir -p "$(dirname "$state_file")"
printf '%s\n' "$opacity" > "$state_file"

# `hyprctl keyword` no sirve con la config en Lua ("keyword can't work with
# non-legacy parsers. Use eval."), así que se aplica llamando a la misma API
# que usa el archivo. El `name` es el de window_rules.lua a propósito: una
# regla con nombre se reemplaza en vez de acumularse.
hyprctl eval "hl.window_rule({
    name = \"opacity-apps\",
    match = { class = \"$class\" },
    opacity = \"$opacity override $opacity override 1.0 override\",
})" >/dev/null
