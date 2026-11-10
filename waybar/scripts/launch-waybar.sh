#!/usr/bin/env bash
# Arranca waybar con el CSS generado para el wallpaper actual. Si todavia no
# hay cache, theme.sh lo crea a partir del wallpaper guardado o del fallback.
set -u

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cache="${XDG_CACHE_HOME:-$HOME/.cache}/waybar/style.css"

if [ ! -s "$cache" ]; then
    "$here/theme.sh" >/dev/null 2>&1 || true
fi

if [ -s "$cache" ]; then
    exec waybar -s "$cache"
fi
exec waybar
