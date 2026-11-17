#!/usr/bin/env python3
"""Convierte la paleta de Waybar en un include de Kitty."""

import colorsys
import re
import sys

DEFAULTS = {
    "neon_solid": "#05080f",
    "neon_accent1": "#00f0ff",
    "neon_accent2": "#ff2bd6",
    "neon_text": "#d9fbff",
    "neon_power": "#ff4d6d",
}


def parse(path):
    colors = dict(DEFAULTS)
    try:
        text = open(path, encoding="utf-8").read()
    except OSError:
        return colors
    for name, value in re.findall(r"@define-color\s+(\w+)\s+(#[0-9a-fA-F]{6})\s*;", text):
        colors[name] = value
    return colors


def rgb(value):
    value = value.lstrip("#")
    return tuple(int(value[i:i + 2], 16) for i in (0, 2, 4))


def hexc(values):
    return "#%02x%02x%02x" % tuple(max(0, min(255, round(c))) for c in values)


def mix(a, b, t):
    return tuple(a[i] * (1 - t) + b[i] * t for i in range(3))


def lighten(value, t=0.18):
    return hexc(mix(rgb(value), (255, 255, 255), t))


def hue_at(value, hue):
    _, l, s = colorsys.rgb_to_hls(*(c / 255 for c in rgb(value)))
    return hexc(tuple(c * 255 for c in colorsys.hls_to_rgb(hue, l, s)))


def main():
    palette = sys.argv[1] if len(sys.argv) > 1 else ""
    c = parse(palette)
    bg = c["neon_solid"]
    accent1 = c["neon_accent1"]
    accent2 = c["neon_accent2"]
    text = lighten(c["neon_text"], 0.25)
    power = c["neon_power"]

    normal = [
        bg,
        power,
        hue_at(accent1, 1 / 3),
        accent2,
        hue_at(accent1, 2 / 3),
        accent2,
        accent1,
        text,
    ]
    bright = [lighten(v, 0.22) for v in normal]
    bright[0] = "#7d8aa5"
    bright[7] = "#ffffff"

    print("# Generado por kitty/theme.py desde waybar; no editar a mano.")
    print("background %s" % bg)
    print("foreground %s" % text)
    print("cursor %s" % accent1)
    print("selection_background %s" % accent2)
    print("selection_foreground %s" % bg)
    for i, value in enumerate(normal):
        print("color%d %s" % (i, value))
    for i, value in enumerate(bright):
        print("color%d %s" % (i + 8, value))


if __name__ == "__main__":
    main()
