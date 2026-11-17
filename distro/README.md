# Mytical distro

Aquí vivirá el empaquetado de la distro. La primera entrega es el **overlay
V1.0** sobre Ubuntu 26.04; la ISO V1.1 se construye después.

Reglas:

- `desktop/` y `branding/` son datos; no escriben fuera de `$HOME`.
- Solo `distro/` e `installer/` pueden tocar `/etc`, `/usr` y systemd.
- APT/version propia posee el escritorio de la ISO; en Preview se conserva Nix.
- Kitty es el terminal por defecto.
- Ningún paquete puede estar a la vez en `apt` y `nix`.

Ver `docs/adr/` y `docs/superpowers/plans/2026-11-12-mytical-distro-v1.md`.
