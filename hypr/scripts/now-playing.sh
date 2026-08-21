#!/usr/bin/env bash
#
# Título de lo que suena, para el label de hyprlock.conf.
#
# hyprlock lo llama una vez por segundo, así que tiene que ser barato y, sobre
# todo, callado: si no hay nada sonando imprime una línea vacía y el label
# desaparece en vez de mostrar un error.

set -u

command -v playerctl >/dev/null 2>&1 || exit 0

# "Stopped" y "Paused" también cuentan como reproductor presente, pero solo
# interesa lo que de verdad está sonando.
[[ "$(playerctl status 2>/dev/null)" == "Playing" ]] || exit 0

artist="$(playerctl metadata artist 2>/dev/null)"
title="$(playerctl metadata title 2>/dev/null)"

[[ -n "$title" ]] || exit 0

if [[ -n "$artist" ]]; then
    text="$artist - $title"
else
    text="$title"
fi

# El texto de los widgets de hyprlock pasa por pango, de modo que un "&" o un
# "<" en el nombre de una canción rompe el marcado y el label deja de pintarse.
text="${text//&/&amp;}"
text="${text//</&lt;}"
text="${text//>/&gt;}"

# Un título largo empuja el resto del layout; 60 caracteres caben de sobra.
if (( ${#text} > 60 )); then
    text="${text:0:59}…"
fi

echo "$text"
