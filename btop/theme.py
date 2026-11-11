#!/usr/bin/env python3
"""Genera el tema de btop desde la paleta de waybar."""

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


def parse(path):
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


def hexc(values):
    return "#%02x%02x%02x" % tuple(max(0, min(255, round(c))) for c in values)


def mix(a, b, t):
    return tuple(a[i] * (1 - t) + b[i] * t for i in range(3))


def main():
    palette = sys.argv[1] if len(sys.argv) > 1 else ""
    c = parse(palette)
    bg = c["neon_solid"]
    fg = c["neon_text"]
    base = hexc(mix(rgb(bg), (255, 255, 255), 0.06))
    selected = hexc(mix(rgb(bg), rgb(c["neon_accent2"]), 0.40))
    accent1 = c["neon_accent1"]
    accent2 = c["neon_accent2"]
    muted = c["neon_muted"]
    power = c["neon_power"]

    values = {
        "main_bg": bg,
        "main_fg": fg,
        "title": accent1,
        "hi_fg": accent1,
        "selected_bg": selected,
        "selected_fg": fg,
        "inactive_fg": muted,
        "graph_text": fg,
        "meter_bg": base,
        "proc_misc": accent2,
        "cpu_box": accent1,
        "mem_box": accent2,
        "net_box": accent1,
        "proc_box": accent1,
        "div_line": base,
        "temp_start": accent1,
        "temp_mid": accent2,
        "temp_end": power,
        "cpu_start": accent1,
        "cpu_mid": accent2,
        "cpu_end": power,
        "free_start": accent1,
        "free_mid": accent2,
        "free_end": power,
        "cached_start": accent1,
        "cached_mid": accent2,
        "cached_end": power,
        "available_start": accent1,
        "available_mid": accent2,
        "available_end": power,
        "used_start": accent1,
        "used_mid": accent2,
        "used_end": power,
        "download_start": accent1,
        "download_mid": accent2,
        "download_end": power,
        "upload_start": accent2,
        "upload_mid": accent1,
        "upload_end": power,
    }

    config = os.environ.get("XDG_CONFIG_HOME") or os.path.join(os.environ["HOME"], ".config")
    out = os.path.join(config, "btop", "themes", "neon.theme")
    os.makedirs(os.path.dirname(out), exist_ok=True)
    with open(out, "w", encoding="utf-8") as fh:
        fh.write("# Tema neon generado desde la paleta de waybar.\n")
        for key, value in values.items():
            fh.write('theme[%s]="%s"\n' % (key, value))


if __name__ == "__main__":
    main()
