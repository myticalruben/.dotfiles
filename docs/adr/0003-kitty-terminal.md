# ADR 0003 — Kitty es el terminal por defecto

**Estado:** aceptado (2026-11-16)

## Contexto

El atajo `MOD+Return` ya abre Kitty. Alacritty tiene una rama de tema neon sin
fusionar y compite por el mismo rol; instalar ambos duplica `.desktop`,
paquetes y configuración.

## Decisión

- Kitty es el terminal por defecto de Mytical V1.
- Alacritty queda como opción externa/experimental, no en la ISO.
- Kitty debe tener tema adaptativo desde la misma paleta que Waybar.
- `MOD+Return` abre Kitty.

## Consecuencias

- Se elimina la duplicación de terminales.
- La rama `feat/alacritty-neon` no se fusiona para V1.
- Hay que crear `kitty/kitty.conf` y su generador de tema.
