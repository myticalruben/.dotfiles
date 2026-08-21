#!/usr/bin/env python3
"""Link every config in this repo into ~/.config (and ~/.local/bin).

Safe to re-run: entries already linked are reported and left alone, and nothing
is ever deleted. Pass --force to repoint symlinks that aim somewhere else.
"""

import sys

USAGE = """Uso: setup.py [OPCIÓN]

  (sin nada)   enlaza las configs; se puede repetir, nunca borra
  --force      además reapunta symlinks que apunten a otro sitio
  --dry-run    dice lo que haría, sin tocar nada
  --unlink     quita los enlaces que apuntan a ESTE repositorio, y solo esos
  -h, --help   este mensaje

--unlink es el paso previo a usar home-manager: los dos caminos quieren ser
dueños de ~/.config y home-manager se niega a pisar un symlink que no creó él.
"""

if "-h" in sys.argv or "--help" in sys.argv:
    print(USAGE)
    raise SystemExit(0)

unknown = [a for a in sys.argv[1:]
           if a not in ("--force", "--dry-run", "--unlink")]
if unknown:
    print(f"Opción desconocida: {unknown[0]} (prueba --help)", file=sys.stderr)
    raise SystemExit(2)

from utils import ccf, summary, unlink, Type  # noqa: E402

print("Quitando los enlaces de estos dotfiles" if unlink
      else "Setting up Hyprland Dotfiles")
print()

ccf("rofi", Type.FOLDER)
ccf("dunst", Type.FOLDER)
ccf("hypr", Type.FOLDER)
ccf("waybar", Type.FOLDER)
ccf("wlogout", Type.FOLDER)
ccf("btop", Type.FOLDER)
ccf("quickshell", Type.FOLDER)
ccf("scripts/volume", Type.BIN)

code = summary()

if not unlink:
    print()
    print("La config de neovim ya no está aquí: vive en")
    print("  https://github.com/myticalruben/nvim")
    print()
    print("Machine-specific settings (monitors, wallpaper) go in")
    print("  hypr/modules/local.lua   - copy it from hypr/modules/local.lua.example")
    print("It is gitignored, so it stays out of the shared config.")

sys.exit(code)
