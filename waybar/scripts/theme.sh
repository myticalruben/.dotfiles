#!/usr/bin/env bash
# Genera la paleta de waybar a partir del wallpaper y deja el CSS en la cache.
# Lo llaman scripts/wallpaper (al cambiar/restaurar) y launch-waybar.sh.
set -u

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
config_dir="${XDG_CONFIG_HOME:-$HOME/.config}/waybar"
cache_dir="${XDG_CACHE_HOME:-$HOME/.cache}/waybar"
style_src="$config_dir/style.css"
style_out="$cache_dir/style.css"
palette="$cache_dir/palette.css"
state="${XDG_STATE_HOME:-$HOME/.local/state}/hypr/wallpaper"

img="${1:-}"
if [ -z "$img" ] && [ -r "$state" ]; then
    img=$(head -n 1 "$state")
fi
if [ -z "$img" ] || [ ! -r "$img" ]; then
    img="$HOME/Pictures/Wallpapers/01.png"
fi

mkdir -p "$cache_dir"
: > "$palette"

magic="$(command -v magick || command -v convert || true)"
py="$(command -v python3 || true)"
if [ -n "$magic" ] && [ -n "$py" ] && [ -r "$img" ]; then
    "$magic" "$img" -resize 160x160 -colors 10 -format %c histogram:info:- 2>/dev/null \
        | "$py" "$here/palette.py" > "$palette" 2>/dev/null || true
fi

cp "$style_src" "$style_out" 2>/dev/null || exit 1

if [ -s "$palette" ] && [ -n "$py" ]; then
    "$py" - "$style_out" "$palette" <<'PY'
import sys

style, palette = sys.argv[1], sys.argv[2]
text = open(style, encoding="utf-8").read()
block = open(palette, encoding="utf-8").read().strip()
start = text.index("/* PALETTE_START */")
end = text.index("/* PALETTE_END */") + len("/* PALETTE_END */")
text = text[:start] + "/* PALETTE_START */\n" + block + "\n/* PALETTE_END */" + text[end:]
open(style, "w", encoding="utf-8").write(text)
PY
fi

# Waybar relee el CSS con SIGUSR2. El binario puede llevar "-s ..." detras.
pids=$(ps -eo pid=,args= | awk '$2 ~ /\/bin\/waybar$/ { print $1 }')
[ -n "$pids" ] && kill -USR2 $pids 2>/dev/null || true
