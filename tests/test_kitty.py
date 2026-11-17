#!/usr/bin/env python3
"""Tests for the adaptive Kitty theme generator.

The generator reads the Waybar palette from a CSS file and writes the Kitty
include.  These tests use synthetic palettes and a temporary HOME/XDG tree so
they never read or write the real user's cache.
"""

import os
import re
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
THEME_PY = ROOT / "kitty" / "theme.py"
THEME_SH = ROOT / "kitty" / "theme.sh"

HEX = re.compile(r"^#[0-9a-fA-F]{6}$")
EXPECTED_KEYS = {
    "background",
    "foreground",
    "cursor",
    "selection_background",
    "selection_foreground",
} | {f"color{i}" for i in range(16)}

DEFAULT_BG = "#05080f"
DEFAULT_ACCENT1 = "#00f0ff"
DEFAULT_ACCENT2 = "#ff2bd6"
DEFAULT_TEXT = "#d9fbff"
DEFAULT_POWER = "#ff4d6d"

PALETTE_A = {
    "neon_solid": "#101820",
    "neon_accent1": "#ff8800",
    "neon_accent2": "#0088ff",
    "neon_text": "#e0e0e0",
    "neon_muted": "#6a7a8c",
    "neon_power": "#ff0044",
}
PALETTE_B = {
    "neon_solid": "#1a0f1f",
    "neon_accent1": "#33ff66",
    "neon_accent2": "#ff33aa",
    "neon_text": "#f0e8ff",
    "neon_muted": "#556677",
    "neon_power": "#ffaa00",
}


def write_palette(path, colors):
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(
        "".join(f"@define-color {name} {value};\n" for name, value in colors.items()),
        encoding="utf-8",
    )
    return path


def parse_theme(text):
    theme = {}
    for raw_line in text.splitlines():
        line = raw_line.strip()
        if not line or line.startswith("#"):
            continue
        key, separator, value = line.partition(" ")
        if not separator:
            continue
        theme[key] = value.strip()
    return theme


def make_env(root, cache_dir=None):
    env = os.environ.copy()
    env["HOME"] = str(root / "home")
    env["XDG_CONFIG_HOME"] = str(root / "config")
    env["XDG_STATE_HOME"] = str(root / "state")
    if cache_dir is None:
        env.pop("XDG_CACHE_HOME", None)
    else:
        env["XDG_CACHE_HOME"] = str(cache_dir)
    return env


class KittyThemeTest(unittest.TestCase):
    def assert_valid_theme(self, theme, output):
        self.assertEqual(set(theme), EXPECTED_KEYS, output)
        for key, value in theme.items():
            self.assertRegex(value, HEX, f"{key}: {value!r}")

    def run_theme_py(self, palette, env):
        return subprocess.run(
            [sys.executable, str(THEME_PY), str(palette)],
            cwd=ROOT,
            env=env,
            text=True,
            capture_output=True,
        )

    def run_theme_sh(self, env):
        return subprocess.run(
            ["bash", str(THEME_SH)],
            cwd=ROOT,
            env=env,
            text=True,
            capture_output=True,
        )

    def test_synthetic_palette_emits_complete_valid_theme(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            palette = write_palette(root / "palette.css", PALETTE_A)
            result = self.run_theme_py(palette, make_env(root))

            self.assertEqual(result.returncode, 0, result.stderr)
            theme = parse_theme(result.stdout)
            self.assert_valid_theme(theme, result.stdout)

            self.assertEqual(theme["background"], PALETTE_A["neon_solid"])
            self.assertEqual(theme["cursor"], PALETTE_A["neon_accent1"])
            self.assertEqual(theme["selection_background"], PALETTE_A["neon_accent2"])
            self.assertEqual(theme["selection_foreground"], PALETTE_A["neon_solid"])
            self.assertEqual(theme["color0"], PALETTE_A["neon_solid"])
            self.assertEqual(theme["color1"], PALETTE_A["neon_power"])
            self.assertEqual(theme["color3"], PALETTE_A["neon_accent2"])
            self.assertEqual(theme["color5"], PALETTE_A["neon_accent2"])
            self.assertEqual(theme["color6"], PALETTE_A["neon_accent1"])
            self.assertEqual(theme["color7"], theme["foreground"])

    def test_distinct_palettes_produce_distinct_accents(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            env = make_env(root)
            palette_a = write_palette(root / "a.css", PALETTE_A)
            palette_b = write_palette(root / "b.css", PALETTE_B)
            result_a = self.run_theme_py(palette_a, env)
            result_b = self.run_theme_py(palette_b, env)

            self.assertEqual(result_a.returncode, 0, result_a.stderr)
            self.assertEqual(result_b.returncode, 0, result_b.stderr)
            theme_a = parse_theme(result_a.stdout)
            theme_b = parse_theme(result_b.stdout)
            self.assert_valid_theme(theme_a, result_a.stdout)
            self.assert_valid_theme(theme_b, result_b.stdout)

            self.assertNotEqual(theme_a["cursor"], theme_b["cursor"])
            self.assertNotEqual(
                theme_a["selection_background"],
                theme_b["selection_background"],
            )
            self.assertNotEqual(theme_a["color6"], theme_b["color6"])
            self.assertNotEqual(theme_a, theme_b)

    def test_missing_palette_falls_back_to_defaults_without_failing(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            env = make_env(root)
            result = self.run_theme_py(root / "does-not-exist.css", env)

            self.assertEqual(result.returncode, 0, result.stderr)
            theme = parse_theme(result.stdout)
            self.assert_valid_theme(theme, result.stdout)
            self.assertEqual(theme["background"], DEFAULT_BG)
            self.assertEqual(theme["cursor"], DEFAULT_ACCENT1)
            self.assertEqual(theme["selection_background"], DEFAULT_ACCENT2)
            self.assertEqual(theme["color1"], DEFAULT_POWER)
            self.assertEqual(theme["color7"], theme["foreground"])

            no_argument = subprocess.run(
                [sys.executable, str(THEME_PY)],
                cwd=ROOT,
                env=env,
                text=True,
                capture_output=True,
            )
            self.assertEqual(no_argument.returncode, 0, no_argument.stderr)
            self.assertEqual(parse_theme(no_argument.stdout), theme)

    def test_bright_black_comes_from_the_palette_muted_colour(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            env = make_env(root)
            palette_a = write_palette(root / "a.css", PALETTE_A)
            palette_b = write_palette(root / "b.css", PALETTE_B)
            result_a = self.run_theme_py(palette_a, env)
            result_b = self.run_theme_py(palette_b, env)
            self.assertEqual(result_a.returncode, 0, result_a.stderr)
            self.assertEqual(result_b.returncode, 0, result_b.stderr)
            theme_a = parse_theme(result_a.stdout)
            theme_b = parse_theme(result_b.stdout)

            self.assertEqual(theme_a["color8"], PALETTE_A["neon_muted"])
            self.assertEqual(theme_b["color8"], PALETTE_B["neon_muted"])
            self.assertNotEqual(theme_a["color8"], theme_b["color8"])

    def test_theme_sh_writes_include_to_xdg_cache(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            cache = root / "cache"
            env = make_env(root, cache)
            write_palette(cache / "waybar" / "palette.css", PALETTE_A)

            result = self.run_theme_sh(env)

            self.assertEqual(result.returncode, 0, result.stderr)
            include = cache / "kitty" / "neon.conf"
            self.assertTrue(include.is_file(), f"missing {include}")
            self.assertFalse((root / "home" / ".cache" / "kitty" / "neon.conf").exists())

            output = include.read_text(encoding="utf-8")
            theme = parse_theme(output)
            self.assert_valid_theme(theme, output)
            self.assertEqual(theme["background"], PALETTE_A["neon_solid"])
            self.assertEqual(theme["cursor"], PALETTE_A["neon_accent1"])
            self.assertEqual(theme["selection_background"], PALETTE_A["neon_accent2"])
            self.assertEqual(theme["color8"], PALETTE_A["neon_muted"])

            # The generated include must not carry the old hardcoded palette.
            lowered = output.lower()
            for stale in (
                "#7d8aa5",
                DEFAULT_BG,
                DEFAULT_ACCENT1,
                DEFAULT_ACCENT2,
                DEFAULT_TEXT,
                DEFAULT_POWER,
            ):
                self.assertNotIn(stale, lowered)
            # theme.sh must pass the palette through, not bake colours into itself.
            self.assertNotRegex(THEME_SH.read_text(encoding="utf-8"), r"#[0-9a-fA-F]{6}")

    def test_theme_sh_falls_back_without_palette(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            cache = root / "cache"
            result = self.run_theme_sh(make_env(root, cache))

            self.assertEqual(result.returncode, 0, result.stderr)
            include = cache / "kitty" / "neon.conf"
            self.assertTrue(include.is_file(), f"missing {include}")
            theme = parse_theme(include.read_text(encoding="utf-8"))
            self.assert_valid_theme(theme, include.read_text(encoding="utf-8"))
            self.assertEqual(theme["background"], DEFAULT_BG)
            self.assertEqual(theme["cursor"], DEFAULT_ACCENT1)
            self.assertEqual(theme["selection_background"], DEFAULT_ACCENT2)

    def test_theme_sh_uses_home_cache_when_xdg_cache_home_is_unset(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            env = make_env(root)
            write_palette(root / "home" / ".cache" / "waybar" / "palette.css", PALETTE_B)

            result = self.run_theme_sh(env)

            self.assertEqual(result.returncode, 0, result.stderr)
            include = root / "home" / ".cache" / "kitty" / "neon.conf"
            self.assertTrue(include.is_file(), f"missing {include}")
            theme = parse_theme(include.read_text(encoding="utf-8"))
            self.assert_valid_theme(theme, include.read_text(encoding="utf-8"))
            self.assertEqual(theme["background"], PALETTE_B["neon_solid"])
            self.assertEqual(theme["cursor"], PALETTE_B["neon_accent1"])
            self.assertEqual(theme["selection_background"], PALETTE_B["neon_accent2"])


if __name__ == "__main__":
    unittest.main()
