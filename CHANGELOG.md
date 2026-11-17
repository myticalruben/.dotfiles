# Changelog

## 0.1.0 — Mytical V1.0 Preview (2026-11-17)

- Overlay instalable sobre Ubuntu 26.04 con APT + Nix.
- `mytical-session`: sesión única Hyprland y wrapper `/usr/bin/mytical-session`.
- `mytical-desktop`: base APT de login, red, audio, portales, keyring, Thunar.
- `mytical-welcome`: primer arranque, comprobaciones y elección de wallpaper.
- Nix 26.05 (`nixos-26.05` + Home Manager `release-26.05`).
- Kitty como terminal por defecto, con paleta adaptativa.
- SDDM solo con la sesión Mytical.
- hypridle, captura regional con grim/slurp y wallpaper dinámico.
- Repo APT local firmado y test aislado.
- Assets propios: throbbers, iconos wlogout y wallpapers CC0.

### Limitaciones conocidas

- La licencia raíz está pendiente (ADR 0008); no publicar ISO.
- Los wallpapers personales no se distribuyen.
- La ISO V1.1 queda fuera de esta entrega.
- El repo APT usa una clave efímera en tests; producción requiere clave real.
