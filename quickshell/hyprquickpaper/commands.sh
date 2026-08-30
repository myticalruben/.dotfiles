#!/usr/bin/env bash
#
# Pone el fondo elegido en el selector. Lo llama shell.qml.
#
# El trabajo lo hace scripts/wallpaper, enlazado en ~/.local/bin: además de
# ponerlo, apunta cuál es, y así modules/autostart.lua lo vuelve a poner en el
# siguiente inicio de sesión.

exec wallpaper set "$1"
