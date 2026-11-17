#!/usr/bin/env bash
# Regenera la paleta de Kitty con el wallpaper actual.
set -u

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cache="${XDG_CACHE_HOME:-$HOME/.cache}/kitty"
palette="${XDG_CACHE_HOME:-$HOME/.cache}/waybar/palette.css"
state="${XDG_STATE_HOME:-$HOME/.local/state}/hypr/wallpaper"

img="${1:-}"
if [ -z "$img" ] && [ -r "$state" ]; then
    img=$(head -n 1 "$state")
fi
mkdir -p "$cache"
if [ ! -s "$palette" ]; then
    theme="${XDG_CONFIG_HOME:-$HOME/.config}/waybar/scripts/theme.sh"
    [ -x "$theme" ] && "$theme" "$img" >/dev/null 2>&1 || true
fi
py="$(command -v python3 || true)"
[ -n "$py" ] || exit 1
"$py" "$here/theme.py" "$palette" > "$cache/neon.conf"
