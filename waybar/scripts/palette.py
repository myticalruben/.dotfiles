#!/usr/bin/env python3
"""Turn an ImageMagick histogram into the waybar neon palette.

Reads `histogram:info:-` lines on stdin and writes the @define-color block used
by style.css. The accent is the most saturated colour that is neither almost
black nor almost white, so the bar picks up the wallpaper instead of always
being cyan/magenta.
"""

import colorsys
import re
import sys

FALLBACK = {
    "bg": (5, 8, 15),
    "accent1": (0, 240, 255),
    "accent2": (255, 43, 214),
    "text": (217, 251, 255),
    "muted": (94, 107, 134),
    "power": (255, 77, 109),
}


def hls(rgb):
    return colorsys.rgb_to_hls(*(c / 255 for c in rgb))


def rgb(h, l, s):
    return tuple(round(c * 255) for c in colorsys.hls_to_rgb(h, l, s))


def mix(a, b, t):
    return tuple(round(a[i] * (1 - t) + b[i] * t) for i in range(3))


def hexc(rgb):
    return "#%02x%02x%02x" % rgb


def rgba(rgb, alpha):
    return "rgba(%d, %d, %d, %s)" % (*rgb, format(alpha, "g"))


def hue_distance(a, b):
    d = abs(a - b) % 360
    return min(d, 360 - d)


def main():
    colours = []
    for line in sys.stdin:
        m = re.search(r"#([0-9a-fA-F]{6})", line)
        if not m:
            continue
        count = re.match(r"\s*(\d+):", line)
        count = int(count.group(1)) if count else 1
        h = m.group(1)
        rgbv = (int(h[0:2], 16), int(h[2:4], 16), int(h[4:6], 16))
        hue, light, sat = hls(rgbv)
        colours.append((count, rgbv, hue * 360, sat, light))

    if not colours:
        colours = [(1, FALLBACK["accent1"], 180, 1.0, 0.5)]

    candidates = []
    for count, rgbv, hue, sat, light in colours:
        if not (0.06 < light < 0.94):
            continue
        if sat < 0.10:
            continue
        # Favour saturated mid-tones; count only breaks near-ties.
        score = sat * (1 - abs(light - 0.55) * 1.35) + min(count / 5000, 0.08)
        candidates.append((score, rgbv, hue, sat, light))

    if not candidates:
        # Fondo plano o en blanco y negro: plata sacada de su tono mas claro.
        lightest = max(colours, key=lambda c: c[4])
        hue, _, _ = hls(lightest[1])
        accent1 = rgb(hue, 0.70, 0.10)
        accent2 = rgb(hue, 0.46, 0.10)
        bg = mix(min(colours, key=lambda c: c[4])[1], (0, 0, 0), 0.35)
        text = mix(accent1, (255, 255, 255), 0.82)
        muted = mix(accent1, (70, 76, 88), 0.62)
        power = FALLBACK["power"]
    else:
        candidates.sort(key=lambda c: c[0], reverse=True)
        _, accent1, hue1, sat1, light1 = candidates[0]
        # Keep the active workspace readable with dark text.
        light1 = min(max(light1, 0.48), 0.78)
        accent1 = rgb(hue1 / 360, light1, max(sat1, 0.55))

        accent2 = None
        for _, rgbv, hue, sat, light in candidates[1:]:
            if sat > 0.2 and hue_distance(hue, hue1) > 40:
                light = min(max(light, 0.45), 0.76)
                accent2 = rgb(hue / 360, light, max(sat, 0.5))
                break
        if accent2 is None:
            accent2 = rgb(((hue1 + 70) % 360) / 360, 0.62, max(sat1 * 0.85, 0.45))

        darkest = min(colours, key=lambda c: c[4])
        bg = mix(darkest[1], (0, 0, 0), 0.35)
        if hls(bg)[1] > 0.22:
            bg = mix(bg, (0, 0, 0), 0.35)

        text = mix(accent1, (255, 255, 255), 0.85)
        muted = mix(accent1, (120, 130, 150), 0.55)
        # Power stays warm; derive it from accent2 only when accent2 already is.
        hue2, _, sat2 = hls(accent2)
        hue2 *= 360
        if not (hue2 >= 320 or hue2 <= 30):
            hue2, sat2 = 345, 0.8
        power = rgb(hue2 / 360, 0.62, max(sat2, 0.65))

    # Sobre un fondo claro las pastillas necesitan mas opacidad para que el
    # texto claro se lea; sobre uno oscuro basta un tinte.
    bg_alpha = 0.55 if max(c[4] for c in colours) > 0.62 else 0.20
    print("@define-color neon_bg %s;" % rgba(mix(bg, (0, 0, 0), 0.1), bg_alpha))
    print("@define-color neon_solid %s;" % hexc(bg))
    print("@define-color neon_tooltip %s;" % rgba(mix(bg, (0, 0, 0), 0.1), 0.96))
    print("@define-color neon_accent1 %s;" % hexc(accent1))
    print("@define-color neon_accent2 %s;" % hexc(accent2))
    print("@define-color neon_soft1 %s;" % rgba(accent1, 0.38))
    print("@define-color neon_soft2 %s;" % rgba(accent2, 0.38))
    print("@define-color neon_glow1 %s;" % rgba(accent1, 0.25))
    print("@define-color neon_glow2 %s;" % rgba(accent2, 0.25))
    print("@define-color neon_text %s;" % hexc(text))
    print("@define-color neon_muted %s;" % hexc(muted))
    print("@define-color neon_power %s;" % hexc(power))
    print("@define-color neon_power_soft %s;" % rgba(power, 0.50))
    print("@define-color neon_power_glow %s;" % rgba(power, 0.25))


if __name__ == "__main__":
    main()
