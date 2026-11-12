#!/usr/bin/env python3
"""Pinta el tema SDDM con la misma paleta neon que Waybar.

Recibe la paleta generada por waybar/scripts/palette.py y reemplaza solo las
claves de color del archivo de configuracion del tema, sin tocar el layout.
"""

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


def lighten(value, t):
    return hexc(mix(rgb(value), (255, 255, 255), t))


def darken(value, t):
    return hexc(mix(rgb(value), (0, 0, 0), t))


def main():
    palette = sys.argv[1] if len(sys.argv) > 1 else ""
    config_path = sys.argv[2] if len(sys.argv) > 2 else ""
    if not config_path:
        raise SystemExit("uso: palette.py PALETA CONFIG")

    c = parse(palette)
    solid = c["neon_solid"]
    accent1 = c["neon_accent1"]
    accent2 = c["neon_accent2"]
    text = lighten(c["neon_text"], 0.28)
    power = c["neon_power"]

    field = lighten(solid, 0.10)
    field_bg = mix(rgb(solid), rgb(accent1), 0.06)
    highlighted = mix(rgb(solid), rgb(accent1), 0.22)
    button = mix(rgb(solid), rgb(accent2), 0.22)

    values = {
        "HeaderTextColor": text,
        "DateTextColor": accent1,
        "TimeTextColor": text,
        "FormBackgroundColor": hexc(mix(rgb(solid), (255, 255, 255), 0.05)),
        "BackgroundColor": solid,
        "DimBackgroundColor": darken(solid, 0.25),
        "LoginFieldBackgroundColor": hexc(field_bg),
        "PasswordFieldBackgroundColor": hexc(field_bg),
        "LoginFieldTextColor": text,
        "PasswordFieldTextColor": text,
        "UserIconColor": accent1,
        "PasswordIconColor": accent2,
        "PlaceholderTextColor": hexc(mix(rgb(text), rgb(solid), 0.55)),
        "WarningColor": power,
        "LoginButtonTextColor": text,
        "LoginButtonBackgroundColor": hexc(button),
        "SystemButtonsIconsColor": accent1,
        "SessionButtonTextColor": accent1,
        "VirtualKeyboardButtonTextColor": accent1,
        "DropdownTextColor": text,
        "DropdownSelectedBackgroundColor": hexc(highlighted),
        "DropdownBackgroundColor": field,
        "HighlightTextColor": text,
        "HighlightBackgroundColor": hexc(highlighted),
        "HighlightBorderColor": accent1,
        "HoverUserIconColor": accent2,
        "HoverPasswordIconColor": accent1,
        "HoverSystemButtonsIconsColor": accent2,
        "HoverSessionButtonTextColor": accent2,
        "HoverVirtualKeyboardButtonTextColor": accent2,
    }

    try:
        lines = open(config_path, encoding="utf-8").read().splitlines()
    except OSError:
        raise SystemExit("no se puede leer %s" % config_path)

    out = []
    seen = set()
    for line in lines:
        m = re.match(r'^([A-Za-z0-9_]+)="[^"]*"$', line)
        if m and m.group(1) in values:
            key = m.group(1)
            out.append('%s="%s"' % (key, values[key]))
            seen.add(key)
        else:
            out.append(line)

    with open(config_path, "w", encoding="utf-8") as fh:
        fh.write("\n".join(out) + "\n")
    missing = sorted(set(values) - seen)
    if missing:
        print("no encontre claves:", ", ".join(missing), file=sys.stderr)


if __name__ == "__main__":
    main()
