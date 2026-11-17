# ADR 0006 — Una sola sesión Hyprland con wrapper de sistema

**Estado:** aceptado (2026-11-16)

## Contexto

Hoy la única sesión es `/usr/local/share/wayland-sessions/hyprland-nix.desktop`
y apunta a `~/.nix-profile`. Si el perfil Nix se rompe, el greeter no tiene
sesión. SDDM lee además `/usr/local` y `/usr/share`, lo que puede duplicar la
entrada.

## Decisión

- La sesión canónica es `/usr/share/wayland-sessions/mytical.desktop`.
- `Exec=/usr/bin/mytical-session`, un wrapper propiedad de APT.
- SDDM fija `SessionDir=/usr/share/wayland-sessions`.
- No se publica una sesión GNOME/Ubuntu.
- En Preview el wrapper puede lanzar Hyprland de Nix; en ISO lanza el de APT.
- Un fallo del wrapper deja al usuario en TTY, no en una sesión vacía.

## Consecuencias

- El entry de sesión no depende de `~/.nix-profile`.
- Hay que migrar `install-hyprland-session` a un paquete.
- La recuperación se documenta por TTY y reinstalación del paquete de sesión.
