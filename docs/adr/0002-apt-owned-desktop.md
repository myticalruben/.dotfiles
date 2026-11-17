# ADR 0002 — APT/version propia es dueño del escritorio en la ISO

**Estado:** aceptado (2026-11-16)

## Contexto

Ubuntu 26.04 ya empaqueta Hyprland 0.53, pero la configuración actual usa Lua
de Hyprland 0.56. Nix puede fijar 0.56, pero su cierre no cabe razonablemente
en el squashfs y duplicaría el compositor si APT también lo instala.

## Decisión

- **Preview V1.0:** el escritorio sigue en Nix, para conservar la versión y la
  configuración actuales.
- **ISO V1.1:** APT (archive de Ubuntu o repo Mytical propio) es dueño del
  compositor, Waybar, portales y apps del sistema. Si la versión de Ubuntu no
  soporta la configuración, Mytical empaqueta Hyprland 0.56 en su repo.
- Nunca se instalan Hyprland, Waybar o Kitty desde APT y Nix a la vez.
- La sesión del sistema se llama `mytical.desktop` y ejecuta
  `/usr/bin/mytical-session`.

## Consecuencias

- La ISO no necesita `/nix` para arrancar.
- La Preview puede usar la configuración actual sin portarla todavía.
- Hay que mantener una matriz de propiedad APT/Nix y probar el par
  Hyprland/portal.
