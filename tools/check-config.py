#!/usr/bin/env python3
"""Comprueba que lo que las configs se referencian entre sí existe de verdad.

Existe por un patrón concreto: casi todo lo que se rompe en estos dotfiles se
rompe *en silencio*. hyprlock llamaba durante meses a un now-playing.sh que no
estaba en el repositorio y el único síntoma era un hueco en la pantalla de
bloqueo; waybar tenía el indicador de escritorios configurado y sin colocar, y
la barra simplemente no lo pintaba. Ninguna de las dos cosas da un error.

No valida sintaxis - para eso están shellcheck y `nix flake check`. Valida
referencias cruzadas, que es donde no hay herramienta que mire.
"""

import json
import re
import sys
from pathlib import Path

REPO = Path(__file__).resolve().parent.parent

# El módulo apunta a un proyecto propio en ~/Documents, no lo instala nada, y
# está fuera de la barra a propósito. Ver packages/manual.md.
WAYBAR_UNPLACED_OK = {"custom/pomobar"}

# waybar los resuelve solos: no necesitan bloque de configuración.
WAYBAR_NO_CONFIG_OK = {"tray"}

problems: list[str] = []


def fail(where: str, what: str) -> None:
    problems.append(f"{where}: {what}")


def read(rel: str) -> str:
    return (REPO / rel).read_text(encoding="utf-8")


def strip_jsonc(text: str) -> str:
    text = re.sub(r"^\s*//.*$", "", text, flags=re.M)
    return re.sub(r",(\s*[}\]])", r"\1", text)


# Una linea comentada no es una referencia: dunstrc es en su mayor parte el
# archivo de muestra de dunst, con ejemplos apuntando a rutas que nunca
# existieron aqui. Marcarlas como rotas seria ruido, y un checker ruidoso se
# acaba ignorando, que es la unica forma de que deje de servir.
COMMENT = re.compile(r"^\s*(#|//|--|\*|/\*)")

SCRIPT_REF = re.compile(r"(?:~|\$HOME)?/?\.config/hypr/(scripts/[\w.-]+)")


def referenced_scripts(text: str):
    for line in text.splitlines():
        if COMMENT.match(line):
            continue
        yield from SCRIPT_REF.findall(line)


def check_referenced_scripts() -> None:
    """Rutas a scripts escritas dentro de las configs."""
    for path in REPO.rglob("*"):
        if not path.is_file() or ".git" in path.parts:
            continue
        try:
            text = path.read_text(encoding="utf-8")
        except (UnicodeDecodeError, OSError):
            continue
        rel = path.relative_to(REPO)
        for match in set(referenced_scripts(text)):
            target = REPO / "hypr" / match
            if not target.exists():
                fail(str(rel), f"apunta a hypr/{match}, que no existe")
            elif not target.stat().st_mode & 0o111:
                fail(str(rel), f"hypr/{match} existe pero no es ejecutable")


def check_shell_scripts() -> None:
    for path in REPO.rglob("*.sh"):
        if ".git" in path.parts:
            continue
        rel = path.relative_to(REPO)
        if not path.read_text(encoding="utf-8").startswith("#!"):
            fail(str(rel), "no empieza con shebang")
        if not path.stat().st_mode & 0o111:
            fail(str(rel), "no es ejecutable")


def check_wlogout() -> None:
    layout = read("wlogout/layout")
    style = read("wlogout/style.css")
    labels = re.findall(r'"label"\s*:\s*"([\w-]+)"', layout)
    icons = {p.stem for p in (REPO / "wlogout/icons").iterdir()}

    for label in labels:
        if label not in icons:
            fail("wlogout/layout", f'"{label}" no tiene wlogout/icons/{label}.png')
        if f"#{label} {{" not in style:
            fail("wlogout/style.css", f'falta la regla #{label} del layout')
    for icon in sorted(icons - set(labels)):
        fail("wlogout/icons", f"{icon}.png no lo usa ninguna entrada del layout")


def check_waybar() -> None:
    try:
        cfg = json.loads(strip_jsonc(read("waybar/config.jsonc")))
    except json.JSONDecodeError as exc:
        fail("waybar/config.jsonc", f"no es JSON válido: {exc}")
        return

    placed = [m for k, v in cfg.items() if k.startswith("modules-") for m in v]
    # Un módulo es "configurable" si lleva "/" (custom, hyprland, ...) o si ya
    # tiene bloque propio; los ajustes sueltos de la barra no cuentan.
    configured = {k for k in cfg if "/" in k or k.split("#")[0] in placed}

    for module in placed:
        if module not in cfg and module not in WAYBAR_NO_CONFIG_OK:
            fail("waybar/config.jsonc", f'"{module}" está colocado y no configurado')
    for module in sorted(configured - set(placed) - WAYBAR_UNPLACED_OK):
        fail("waybar/config.jsonc",
             f'"{module}" está configurado y no aparece en ningún modules-*')


def check_rofi_imports() -> None:
    text = read("rofi/config.rasi")
    for target in re.findall(r'@import\s+"([^"]+)"', text):
        if not (REPO / "rofi" / target).exists():
            fail("rofi/config.rasi", f"@import \"{target}\" no existe")


def check_setup_sources() -> None:
    for name in re.findall(r'ccf\("([^"]+)"', read("setup.py")):
        if not (REPO / name).exists():
            fail("setup.py", f'enlaza "{name}", que no está en el repositorio')


def main() -> int:
    for check in (check_referenced_scripts, check_shell_scripts, check_wlogout,
                  check_waybar, check_rofi_imports, check_setup_sources):
        check()

    if problems:
        print(f"{len(problems)} referencia(s) rota(s):\n")
        for problem in problems:
            print(f"  {problem}")
        return 1

    print("Todas las referencias entre configs resuelven.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
