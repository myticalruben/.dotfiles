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
