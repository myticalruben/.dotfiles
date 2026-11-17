# Progreso de Mytical

## 2026-11-16 — V1.0 overlay aprobado

- Decisiones registradas en `docs/adr/0001`–`0007`.
- Plan y especificación actualizados.
- Creada la matriz `distro/ownership.json` y `tools/check-ownership.py`.
- Tests iniciales de propiedad y de enlaces de `setup.py`.
- `setup.py` ahora enlaza `session-start`, `session-splash`, `set-zsh-shell`,
  `gtk-theme`, `btop-theme`, `btop.conf` y `Pictures/Wallpapers`.
- Pendiente P0: licencia raíz, ramas, graphify tracking, `hyprshot`,
  `hypridle`, tests de `utils.py`, paquetes `mytical-*`.

## 2026-11-17 — Paquetes y Kitty

- Creado `kitty/kitty.conf` + `kitty/theme.py` + `kitty/theme.sh`; la paleta
  se regenera con el wallpaper y `scripts/wallpaper` la aplica.
- Creados `mytical-session` y `mytical-desktop` con `dpkg-deb` (sin debhelper).
- `mytical-session` instala el wrapper `/usr/bin/mytical-session`, la sesión
  única y la configuración de SDDM.
- Tests de paquete y de ownership pasan.
- La VM 10.0.0.146 no estaba accesible al intentar instalar el paquete; queda
  pendiente el smoke test de instalación.

## 2026-11-17 — Atajo de captura

- `SUPER+O` ya no depende de `hyprshot` (no empaquetado): usa `grim` + `slurp`.
- Se retiró `hyprshot` de la matriz de propiedad hasta empaquetarlo.

## 2026-11-17 — Sesión endurecida

- `mytical-session` ahora trae postinst/postrm seguros.
- Test `distro/tests/test_session.sh`: wrapper, desktop, conffiles, ausencia de
  GNOME/Ubuntu y simulación de systemctl.
- `make -C distro test` pasa completo.

## 2026-11-17 — Tests de Kitty

- 7 tests de paleta, fallback y cache.
- Corregido color8 para usar `neon_muted` de la paleta.

## 2026-11-17 — Repo APT

- `distro/apt/Makefile` construye, firma y prueba un repo local con
  `apt-ftparchive` y GnuPG.
- Test real: `apt-get update` en un root temporal resuelve `mytical-session`
  y descarga un `.deb` idéntico.
- `distro/apt/public/` queda ignorado.

## 2026-11-17 — Nix 26.05 y auditoría legal

- `flake.nix` fijado a `nixos-26.05` y Home Manager `release-26.05`.
- `flake.lock` actualizado desde la VM.
- Auditoría de assets en `docs/distro/ASSET-LICENSES.md`; la ISO no es publicable
  hasta resolver throbbers CachyOS, wallpapers, iconos wlogout y licencia raíz.

## 2026-11-17 — VM y Nix 26.05

- `mytical-session` instalado en Ubuntu 26.04; SDDM muestra solo
  `Mytical (Wayland)`.
- `nix flake check` y build de `homeConfigurations.default` con
  `nixos-26.05`/`release-26.05` terminan OK.
- Fijado `gtk.gtk4.theme` para conservar el comportamiento legacy sin warning.
- La auditoría legal mantiene bloqueada la publicación de la ISO hasta resolver
  assets P0.

## 2026-11-17 — Smoke real de sesión

- Perfil Nix 26.05 activado en la VM (`Hyprland 0.55.4`).
- Autologin temporal de SDDM a `mytical`: Hyprland arrancó, Waybar y dunst
  quedaron activos, wallpaper restaurado e hypridle en ejecución.
- `grim` confirmó 1280x800 y la sesión completa.
- Autologin retirado y SDDM vuelto a dejar en el login normal.

## 2026-11-17 — Assets propios

- Reemplazados los 41 throbbers de CachyOS por un anillo animado propio.
- Reemplazados los 5 iconos de wlogout por line-art propio.
- Los wallpapers y la licencia raíz siguen bloqueando la publicación.

## 2026-11-17 — Meta de escritorio y duplicados

- `mytical-desktop` instalado; Thunar y nm-applet pasan a ser de APT.
- Se retiraron `thunar` y `networkmanagerapplet` del perfil Nix para no duplicar
  binarios ni entradas de lanzador.
- zsh de login sigue Nix en la Preview; en la ISO será del sistema (ADR 0002).

## 2026-11-17 — mytical-welcome

- Paquete `mytical-welcome` construido, instalado y verificado en la VM.
- `mytical-welcome --check`: python3, nix, home-manager, hyprctl, kitty,
  sddm y wallpaper en OK.
- La guía explica APT/Nix y permite elegir wallpaper sin root.

## 2026-11-17 — Set de wallpapers propio

- Cuatro wallpapers originales CC0 en `distro/branding/wallpapers/`.
- Los wallpapers personales quedan fuera de la distribución.
- Licencia raíz del código sigue pendiente de decisión.
