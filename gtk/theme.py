#!/usr/bin/env python3
"""Genera el CSS neon de GTK3/GTK4 desde la paleta de waybar."""

import os
import re
import sys

DEFAULTS = {
    "neon_solid": "#05080f",
    "neon_accent1": "#00f0ff",
    "neon_accent2": "#ff2bd6",
    "neon_text": "#d9fbff",
    "neon_muted": "#5e6b86",
    "neon_power": "#ff4d6d",
}


def parse_palette(path):
    colors = dict(DEFAULTS)
    try:
        text = open(path, encoding="utf-8").read()
    except OSError:
        return colors
    for name, value in re.findall(r"@define-color\s+(\w+)\s+(#[0-9a-fA-F]{6})\s*;", text):
        colors[name] = value
    return colors


def rgb(hexv):
    h = hexv.lstrip("#")
    return tuple(int(h[i:i + 2], 16) for i in (0, 2, 4))


def hexc(rgbv):
    return "#%02x%02x%02x" % tuple(max(0, min(255, round(c))) for c in rgbv)


def mix(a, b, t):
    return tuple(a[i] * (1 - t) + b[i] * t for i in range(3))


def render(template, values):
    text = open(template, encoding="utf-8").read()
    for key, value in values.items():
        text = text.replace(key, value)
    return text


def main():
    palette = sys.argv[1] if len(sys.argv) > 1 else ""
    c = parse_palette(palette)
    bg = c["neon_solid"]
    base = hexc(mix(rgb(bg), (255, 255, 255), 0.04))
    accent = c["neon_accent1"]
    accent2 = c["neon_accent2"]

    def rgba(hexv, alpha):
        r, g, b = rgb(hexv)
        return "rgba(%d, %d, %d, %s)" % (r, g, b, format(alpha, "g"))

    values = {
        "__BG__": bg,
        "__BASE__": base,
        "__FG__": c["neon_text"],
        "__ACCENT__": accent,
        "__ACCENT2__": accent2,
        "__MUTED__": c["neon_muted"],
        "__POWER__": c["neon_power"],
        "__ACCENT_SOFT__": rgba(accent, 0.35),
        "__ACCENT_STRONG__": rgba(accent, 0.55),
        "__ACCENT_GLOW__": rgba(accent, 0.16),
        "__ACCENT2_SOFT__": rgba(accent2, 0.35),
    }

    here = os.path.dirname(os.path.abspath(__file__))
    config = os.environ.get("XDG_CONFIG_HOME") or os.path.join(os.environ["HOME"], ".config")
    targets = {
        "gtk-3.0/gtk.css": os.path.join(here, "gtk-3.0.css.in"),
        "gtk-4.0/gtk.css": os.path.join(here, "gtk-4.0.css.in"),
    }
    for rel, template in targets.items():
        out = os.path.join(config, rel)
        os.makedirs(os.path.dirname(out), exist_ok=True)
        with open(out, "w", encoding="utf-8") as fh:
            fh.write(render(template, values))


if __name__ == "__main__":
    main()
