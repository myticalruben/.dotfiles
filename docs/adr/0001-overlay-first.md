# ADR 0001 — Overlay V1.0 antes de la ISO

**Estado:** aceptado (2026-11-16)

## Contexto

El repositorio es una configuración de usuario, no una distro. La vía sin Nix
está rota (faltan scripts de sesión y wallpaper), `~/.config` tiene tres
posibles dueños y el cierre Nix pesa ~3,8 GiB. Construir una ISO antes de
resolver eso produce una imagen que falla en el primer login.

## Decisión

La primera entrega es un **overlay instalable sobre Ubuntu 26.04**:

- repo APT `mytical-*`;
- APT para el sistema;
- Nix/Home Manager para el escritorio actual;
- SDDM, sesión única y branding empaquetados;
- `mytical-welcome` para el primer arranque.

La ISO V1.1 se construye después, cuando el overlay pase las pruebas de VM.

## Consecuencias

- Se puede validar APT+Nix sin Calamares.
- El cierre Nix no se hornea en una ISO.
- La ISO no se promete hasta que el overlay sea reproducible.
- Se documenta la diferencia entre Preview y V1.1 en el README.
