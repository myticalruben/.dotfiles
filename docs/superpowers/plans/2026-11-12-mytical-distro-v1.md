# Mytical 26.04 — Plan de implementación de la V1

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Publicar una primera versión instalable de Mytical basada en Ubuntu 26.04, con APT para el sistema y Nix/Home Manager en la Preview. La primera entrega es un overlay; la ISO V1.1 es un remaster casper con APT como dueño del escritorio y Nix opcional, sin `/nix` en el squashfs.

**Architecture:** Primero overlay sobre Ubuntu 26.04 con paquetes `mytical-*` y Home Manager; después remaster casper de la ISO oficial + Calamares, con APT como dueño del escritorio y Nix opcional. SDDM con branding Mytical; sin GNOME Shell, GDM ni `ubuntu-session`.

**Tech Stack:** Ubuntu 26.04, live-build, Calamares, debhelper, reprepro/aptly, GPG, Nix flakes, Home Manager, nixGL, QEMU/KVM, GitHub Actions.

**Spec:** `docs/superpowers/specs/2026-11-12-mytical-distro-v1.md`

## Baseline actual

- Ubuntu 26.04.1 (`resolute`) en `10.0.0.146`.
- SDDM activo, sesión única `/usr/local/share/wayland-sessions/hyprland-nix.desktop`.
- GNOME Shell, GDM, `ubuntu-session` y apps GNOME ya eliminados; se conservaron keyring, GVfs, portales, polkit, NetworkManager, Xorg y temas.
- El escritorio Hyprland/Waybar/Quickshell/Alacritty/btop vive en Nix; SDDM/Plymouth/GTK están instalados por APT.
- El repo mezcla dotfiles, instalador, paquetes APT, temas de sistema y CI; no hay ISO ni paquete instalable.
- `packages/ubuntu.txt` está pensado para 24.04 y duplica paquetes que también instala Nix.
- Nix usa `nixos-unstable` sin rama de release; `flake.lock` fija versiones.
- No hay pruebas de instalación/ISO ni build reproducible.

## Hallazgos P0 que cambian el orden

- Corregir la propiedad de `~/.config` y el autostart antes de empaquetar: `setup.py` no enlaza `session-start`, `session-splash`, `gtk-theme` ni `btop-theme`.
- No usar `mkOutOfStoreSymlink` en la imagen: copiar configuración inmutable o empaquetarla.
- Añadir `LICENSE` raíz y `THIRD_PARTY_NOTICES` (SDDM GPL, Audiowide OFL, arte CachyOS) antes de publicar.
- Sacar `graphify-out/` del árbol versionado y versionar `docs/`.
- No depender de PPAs para Hyprland/waybar/alacritty; para la ISO, el compositor sale del archive/repo Mytical o se fija una versión propia.
- No se hornea `/nix` en el squashfs de la V1.1; Nix se instala como gestor opcional.
- La Preview V1.0 no exige cierre Nix offline; se documenta que Nix se instala en el primer uso.
- Medir el cierre Nix (3,8 GiB en el baseline). Si supera el presupuesto de ISO, la V1 será overlay primero.
- Cerrar las ramas `feat/*` muertas y crear tags/releases antes de llamar a esto V1.
- Elegir un solo dueño del compositor y un solo terminal (kitty en V1); eliminar el Hyprland/Alacritty/kitty duplicado de APT y Nix.
- `hyprshot` no está en ninguna vía: empaquetarlo o reescribir `SUPER+O` con `grim`/`slurp`.
- Pasar Home Manager a salida pura en producción: `mkHome { username, homeDirectory }` y `store` por defecto; dejar `mkOutOfStoreSymlink`/`--impure` solo en modo dev.
- Incluir `nix flake archive` además del cierre de paquetes; sin fuentes de inputs no hay primer login offline.
- Unificar la paleta: `rofi`, `dunst`, `kitty` y SDDM deben consumir la misma fuente; Plymouth debe dejar de ser una tercera identidad o declararse marca fija.
- Añadir `hypridle`, `hyprshot` y las apps base/MIME; sin ellas la distro se siente incompleta.
- Publicar wallpaper/paleta en `/var/lib/mytical` para que el greeter no dependa de `/home`.
- Auditar licencias de wallpapers, iconos wlogout y arte CachyOS antes de publicar.

## Global Constraints

- Base: Ubuntu 26.04 LTS `resolute`, x86_64.
- Una sola sesión: `mytical.desktop`; sin GNOME Shell, GDM ni `ubuntu-session`.
- **Kitty** es el terminal por defecto; Alacritty no entra en V1.
- **Nix estable 26.05**: `nixos-26.05` y `release-26.05` (no `nixos-unstable`).
- **APT/version propia** posee el escritorio de la ISO; la Preview conserva Nix.
- **Jarvis híbrido local-first**, cloud solo con consentimiento explícito.
- APT posee kernel, firmware, drivers, SDDM, red, audio, portales, keyring, polkit y Xorg.
- Nix posee Hyprland, Waybar, Quickshell y apps de usuario; ningún binario puede pertenecer a ambos.
- La sesión APT base de la ISO debe funcionar sin Nix; Nix es opcional y no se hornea en el squashfs.
- La ISO debe arrancar en UEFI y BIOS.
- Los paquetes y la ISO deben estar firmados y tener checksums.
- No se reclama ser Ubuntu oficial; se incluye aviso de marca.
- V1 no implementa Jarvis; solo reserva la interfaz.
- No `autoremove` en scripts de instalación sin simulación y lista explícita.

## Review Focus

- **Duplicación APT/Nix:** el mismo binario o fuente instalado por los dos gestores; una actualización pisa a la otra. Test: `tools/check-ownership.py` falla con solapamientos.
- **Primer login de la ISO sin red:** la sesión APT intenta depender de Nix/Home Manager y deja al usuario en una sesión vacía. Test: QEMU sin red, login Hyprland APT, sin `/nix`; Nix es opcional.
- **Sesión única:** después de instalar aparecen Ubuntu/GNOME en SDDM o se puede entrar a una sesión sin Hyprland. Test: `ls /usr/share/wayland-sessions` y `sddm-greeter --test-mode`.
- **Paquetes base arrastrados por autoremove:** actualizar/quitar un meta elimina Xorg, SDDM, keyring o portales. Test: simulación de upgrade y matriz de paquetes críticos.
- **Hardware:** NVIDIA/nixGL y Secure Boot impiden arrancar la sesión. Test: QEMU con GPU virtual y checklist NVIDIA/Secure Boot.

---

### Task 0: Freeze del baseline y matriz de propiedad

**Files:**
- Create: `distro/ownership.yaml`
- Create: `tools/check-ownership.py`
- Create: `docs/distro/BASELINE.md`
- Modify: `.github/workflows/check.yml`

**Interfaces:**
- Produces: `distro/ownership.yaml` con listas `apt:` y `nix:`; `tools/check-ownership.py --check` sale 0 si no hay solapamientos y 1 si los hay.

- [ ] **Step 1: Escribir el test que falla**

Crear un fixture con `apt: [hyprland]` y `nix: [hyprland]`; ejecutar `python3 tools/check-ownership.py --check distro/ownership.yaml`; esperar salida 1 y el mensaje `solapamiento: hyprland`.

- [ ] **Step 2: Implementar el checker**

El script acepta `--check RUTA`, parsea YAML sin dependencias externas (o usa `python3-yaml` empaquetado), normaliza nombres y falla si un nombre aparece en ambas listas. Añadir el paso a CI.

- [ ] **Step 3: Crear la matriz real**

Documentar en `distro/ownership.yaml` los paquetes del baseline: APT (sddm, xorg, network-manager, pipewire, wireplumber, portales, keyring, gvfs, polkit, thunar, zsh, direnv, plymouth) y Nix (hyprland, waybar, quickshell, rofi, dunst, wlogout, alacritty, btop, hyprlock, cliphist, grim, slurp).

- [ ] **Step 4: Verificar**

Run: `python3 tools/check-ownership.py --check distro/ownership.yaml`
Expected: `OK: 0 solapamientos`.

- [ ] **Step 5: Commit**

```bash
git add distro/ownership.yaml tools/check-ownership.py docs/distro/BASELINE.md .github/workflows/check.yml
git commit -m "chore(distro): fijar baseline y propiedad apt/nix"
```

### Task 0b: Preflight de propiedad, licencias e higiene

**Files:**
- Create: `LICENSE`, `THIRD_PARTY_NOTICES`
- Create: `tests/test_utils.py`, `tests/test_check_config.py`
- Modify: `setup.py` o retirarlo, `scripts/session-start`, `hypr/modules/autostart.lua`, `.gitignore`, `.github/workflows/check.yml`

**Interfaces:**
- Produces: `make check` con tests de `utils.py` y `check-config.py`; `setup.py` enlaza todo lo que la sesión ejecuta o se declara obsoleto; `LICENSE` y avisos de terceros presentes.

- [ ] **Step 1: Test de autostart**

Crear un HOME temporal, ejecutar `python3 setup.py --force` y comprobar que `~/.local/bin/session-start`, `session-splash`, `gtk-theme/theme.sh` y `btop-theme/theme.sh` resuelven; después ejecutar `session-start --dry-run` (o el chequeo equivalente) y esperar 0.

- [ ] **Step 2: Verificar fallo**

Run: `pytest tests/test_utils.py tests/test_check_config.py -q`
Expected: FAIL porque faltan tests/ficheros.

- [ ] **Step 3: Implementar**

Añadir tests de `utils.py` (symlink ajeno, directorio real, `--unlink`, `--dry-run`, `--force`), fixtures positivas/negativas de `check-config.py`, y un test que exige que cada comando de `session-start` esté enlazado por la vía soportada. Corregir `setup.py` o retirarlo de la imagen. Añadir licencias y `graphify-out/` a `.gitignore`.

- [ ] **Step 4: Verificar**

Run: `pytest tests/test_utils.py tests/test_check_config.py -q && python3 tools/check-config.py`
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add LICENSE THIRD_PARTY_NOTICES tests setup.py scripts/session-start hypr/modules/autostart.lua .gitignore .github/workflows/check.yml
git commit -m "chore(dist): cerrar propiedad y licencias antes de empaquetar"
```

### Task 1: Separar el repositorio en capas de distro

**Files:**
- Create: `distro/README.md`
- Create: `distro/apt/`, `distro/debian/`, `distro/iso/`, `distro/installer/`, `distro/branding/`, `distro/first-run/`
- Modify: `README.md`, `.gitignore`

**Interfaces:**
- Produces: `distro/` como raíz de empaquetado; `nix/` y las configs de escritorio permanecen en su sitio para no romper Home Manager.
- Consumes: matriz de Task 0.

- [ ] **Step 1: Escribir el test de estructura**

Crear `distro/tests/test_layout.sh` que compruebe que existen `distro/debian/control` (o paquete concreto), `distro/iso/`, `distro/installer/` y que `nix/home.nix` sigue en su ruta.

- [ ] **Step 2: Ejecutar el test**

Run: `bash distro/tests/test_layout.sh`
Expected: FAIL por directorios ausentes.

- [ ] **Step 3: Crear la estructura y documentar**

Crear los directorios con READMEs de una responsabilidad cada uno. Mover únicamente lo que pertenece al sistema (`ubuntu/sddm`, `ubuntu/plymouth`) a `distro/branding/` manteniendo enlaces o una nota de migración; no mover `nix/` ni `hypr/` en esta tarea.

- [ ] **Step 4: Verificar**

Run: `bash distro/tests/test_layout.sh && python3 tools/check-config.py`
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add distro README.md .gitignore
git commit -m "refactor(distro): separar capas de empaquetado"
```

### Task 2: Repo APT local firmado

**Files:**
- Create: `distro/apt/Makefile`, `distro/apt/reprepro.conf`, `distro/apt/README.md`
- Create: `distro/tests/test_apt_repo.sh`

**Interfaces:**
- Produces: `make -C distro/apt repo` genera `distro/apt/public/dists/...` y `Packages.gz`; `make -C distro/apt sign` firma con la clave `Mytical Archive`.

- [ ] **Step 1: Test de repo**

El test construye un `.deb` dummy, lo añade con `reprepro`, sirve `distro/apt/public` con `python3 -m http.server` y ejecuta `apt-get update` en un contenedor/`chroot` con `deb [signed-by=...] http://127.0.0.1:... ./`.

- [ ] **Step 2: Verificar fallo**

Run: `bash distro/tests/test_apt_repo.sh`
Expected: FAIL porque no existe el repo.

- [ ] **Step 3: Implementar**

Configurar `reprepro` (o `aptly` si se decide) con `origin Mytical`, `label Mytical`, `codename mytical`, clave GPG dearchive. Añadir `make repo sign test`.

- [ ] **Step 4: Verificar**

Run: `make -C distro/apt repo sign test`
Expected: `apt-get update` sin errores de firma y `apt-cache policy` muestra el repo.

- [ ] **Step 5: Commit**

```bash
git add distro/apt
git commit -m "build(apt): repo local firmado"
```

### Task 3: Metapaquete mytical-desktop

**Files:**
- Create: `distro/debian/mytical-desktop/debian/control`
- Create: `distro/debian/mytical-desktop/debian/rules`
- Create: `distro/debian/mytical-desktop/debian/install`
- Create: `distro/tests/test_metapackage.sh`

**Interfaces:**
- Produces: paquete `mytical-desktop` que depende de SDDM, Xorg, NetworkManager, PipeWire, WirePlumber, portales, keyring, GVfs, polkit, Thunar, zsh, direnv, fontconfig y Plymouth.
- Consumes: `distro/ownership.yaml`.

- [ ] **Step 1: Test de dependencias**

El test ejecuta `dpkg-deb -f ... Depends` y comprueba que están `sddm`, `xserver-xorg`, `network-manager`, `network-manager-gnome`, `pipewire`, `pipewire-pulse`, `wireplumber`, `xdg-desktop-portal-hyprland`, `gnome-keyring`, `libpam-gnome-keyring`, `gvfs`, `polkitd`, `hypridle`, `hyprshot`; y que **no** están `ubuntu-session`, `gdm3`, `gnome-shell`.

- [ ] **Step 2: Verificar fallo**

Run: `bash distro/tests/test_metapackage.sh`
Expected: FAIL si el paquete no existe.

- [ ] **Step 3: Implementar**

Crear el paquete con `debhelper-compat` 13, `Section: metapackages`, `Architecture: all`; documentar que Nix no se instala por APT. El metapaquete no puede depender de PPAs de terceros; si un paquete no está en Ubuntu 26.04, se empaqueta en el repo Mytical o se descopar. Incluir `hypridle`, `hyprshot` o su reemplazo, apps base, MIME, `fonts-nerd` propia y `network-manager-gnome` (nm-applet). Añadir `lintian` y una comprobación de que `apt-get autoremove -s` no incluye la matriz crítica.

- [ ] **Step 4: Verificar**

Run: `bash distro/tests/test_metapackage.sh && lintian distro/build/mytical-desktop_*.deb`
Expected: PASS, sin errores.

- [ ] **Step 5: Commit**

```bash
git add distro/debian/mytical-desktop distro/tests/test_metapackage.sh
git commit -m "feat(apt): metapaquete mytical-desktop"
```

### Task 4: Paquete mytical-session

**Files:**
- Create: `distro/debian/mytical-session/debian/control`
- Create: `distro/debian/mytical-session/usr/share/wayland-sessions/mytical.desktop`
- Create: `distro/debian/mytical-session/etc/sddm.conf.d/90-mytical.conf`
- Create: `distro/debian/mytical-session/etc/xdg-desktop-portal/portals.conf`
- Create: `distro/debian/mytical-session/usr/bin/mytical-session`
- Create: `distro/debian/mytical-session/usr/lib/systemd/user/mytical-session.target`
- Create: `distro/tests/test_session.sh`

**Interfaces:**
- Produces: sesión `/usr/share/wayland-sessions/mytical.desktop` con `Exec=/usr/bin/mytical-session`; wrapper que fija PATH/entorno; SDDM `Current=mytical`, `SessionDir=/usr/share/wayland-sessions`, `DisplayServer=x11`; portal `default=gtk` + `ScreenCast=hyprland`; target de usuario con waybar/dunst/awww/cliphist/nm-applet supervisados.

- [ ] **Step 1: Test de sesión única**

En una VM limpia, instalar el paquete y comprobar que `/usr/share/wayland-sessions` solo contiene `mytical.desktop`, que no hay `ubuntu.desktop` y que `sddm-greeter --test-mode` muestra solo Mytical.

- [ ] **Step 2: Verificar fallo**

Run: `bash distro/tests/test_session.sh`
Expected: FAIL porque no existe el paquete.

- [ ] **Step 3: Implementar**

Empaquetar la sesión, wrapper, configuración de SDDM/portales y unidades de usuario con `Restart=on-failure`. No incluir archivos en `/home`; el wrapper es dueño del PATH y llama a Hyprland del sistema o al perfil Nix según el modo. Añadir `Conflicts: ubuntu-session, gdm3` y un `SessionDir` explícito para no duplicar el entry en `/usr/local` y `/usr/share`.

- [ ] **Step 4: Verificar**

Run: `bash distro/tests/test_session.sh`
Expected: PASS; journal de SDDM sin errores.

- [ ] **Step 5: Commit**

```bash
git add distro/debian/mytical-session distro/tests/test_session.sh
git commit -m "feat(apt): sesion unica mytical"
```

### Task 5: mytical-release y branding

**Files:**
- Create: `distro/debian/mytical-release/debian/control`
- Create: `distro/debian/mytical-release/etc/os-release`
- Create: `distro/debian/mytical-branding/...` (SDDM, Plymouth, wallpapers, fuentes)
- Create: `distro/branding/branding.conf` (una sola fuente de nombre/acento/logo)
- Create: `docs/distro/TRADEMARK.md`, `docs/distro/ASSET-LICENSES.md`

**Interfaces:**
- Produces: `/etc/os-release` con `ID=mytical`, `ID_LIKE=ubuntu`, `UBUNTU_CODENAME=resolute`; assets en `/usr/share/mytical/branding/`; helper `/usr/libexec/mytical/mytical-palette` que publica wallpaper/paleta en `/var/lib/mytical` para SDDM.

- [ ] **Step 1: Test de identidad**

El test comprueba `NAME`, `ID`, `ID_LIKE`, `VERSION_ID=26.04`, que no se usa el logo oficial de Ubuntu en SDDM/Plymouth y que existe el aviso de marca.

- [ ] **Step 2: Verificar fallo**

Run: `bash distro/tests/test_identity.sh`
Expected: FAIL.

- [ ] **Step 3: Implementar**

Crear paquetes separados `mytical-release` y `mytical-branding`; incluir licencias OFL de Audiowide, aviso de CachyOS, auditoría de wallpapers/iconos wlogout y aviso de marca Ubuntu. Unificar `branding.conf` como fuente de nombre/acento/logo; `mytical-palette` genera CSS/GTK/btop/SDDM. No sobrescribir `/etc/os-release` de Ubuntu sin `Conflicts`/`Replaces` explícitos.

- [ ] **Step 4: Verificar**

Run: `bash distro/tests/test_identity.sh && dpkg -c distro/build/mytical-release_*.deb`
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add distro/debian/mytical-release distro/debian/mytical-branding docs/distro/TRADEMARK.md
git commit -m "feat(apt): identidad y branding mytical"
```

### Task 6: Bootstrap Nix offline y Home Manager

**Files:**
- Create: `distro/debian/mytical-nix-bootstrap/debian/control`
- Create: `distro/nix/build-closure.sh`
- Create: `distro/nix/install-offline.sh`
- Create: `distro/tests/test_nix_offline.sh`
- Modify: `flake.nix` (pin release branch or document unstable pin)

**Interfaces:**
- Produces: `/usr/share/mytical/nix/flake` con el repo y `flake.lock`; `/usr/share/mytical/nix/store` con el cierre; `mytical-nix-bootstrap` que instala/verifica Nix y ejecuta `home-manager switch --flake /usr/share/mytical/nix/flake#default --impure`.

- [ ] **Step 1: Test offline**

En QEMU sin red, ejecutar `mytical-nix-bootstrap --user test`; comprobar `command -v Hyprland`, `home-manager` y que no hay descargas.

- [ ] **Step 2: Verificar fallo**

Run: `bash distro/tests/test_nix_offline.sh`
Expected: FAIL porque no existe el cierre.

- [ ] **Step 3: Implementar**

Partir `nix/home.nix` en módulos (`packages-cli`, `packages-gui`, `configs`, `session`, `gl`, `fonts`, `zsh`); crear `mkHome { username, homeDirectory }` puro y `store` por defecto; dejar `mkOutOfStoreSymlink` y `--impure` solo en `nix/dev.nix`. Fijar `nixpkgs` a `nixos-26.05` y Home Manager a `release-26.05`; actualizar `flake.lock`. Instalar Nix desde un paquete/instalador vendorizado, nunca `curl | sh`; el daemon es del sistema, el perfil es del usuario. Incluir `hyprshot` o reemplazar el atajo. **No incluir el cierre Nix en la ISO V1.1**: Nix es opcional y se instala después. Añadir `nix flake check` que construya la activación, y un smoke de `home-manager switch` en la Preview.

- [ ] **Step 4: Verificar**

Run: `bash distro/tests/test_nix_offline.sh && nix flake check --no-build`
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add distro/debian/mytical-nix-bootstrap distro/nix distro/tests/test_nix_offline.sh flake.nix
git commit -m "feat(nix): bootstrap offline para la distro"
```

### Task 7: mytical-welcome / primer arranque

**Files:**
- Create: `distro/first-run/mytical-welcome` (Python/GTK o TUI)
- Create: `distro/debian/mytical-welcome/...`
- Create: `distro/tests/test_welcome.sh`

**Interfaces:**
- Consumes: `mytical-nix-bootstrap`, `scripts/wallpaper`, `home-manager`, `mytical-palette`.
- Produces: comando `mytical-welcome` idempotente que verifica Nix, activa Home Manager, elige wallpaper y muestra el estado de APT/Nix; siembra apps/MIME, terminal tematizada, `hypridle`/`hyprshot` y accesibilidad.

- [ ] **Step 1: Test de idempotencia**

Ejecutar dos veces en una VM limpia; la segunda no debe cambiar archivos ni pedir permisos root.

- [ ] **Step 2: Verificar fallo**

Run: `bash distro/tests/test_welcome.sh`
Expected: FAIL.

- [ ] **Step 3: Implementar**

TUI mínima para V1 (sin dependencias nuevas); escribe `~/.config/mytical/first-run.json`; lanza `home-manager switch` y `wallpaper restore`; muestra `apt`/`nix` versions; configura TZ/teclado/idioma/wallpaper y aplica la paleta a SDDM/GTK/rofi/dunst/kitty. No ejecutar `autoremove`.

- [ ] **Step 4: Verificar**

Run: `bash distro/tests/test_welcome.sh`
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add distro/first-run distro/debian/mytical-welcome distro/tests/test_welcome.sh
git commit -m "feat(distro): primer arranque mytical-welcome"
```

### Task 8: Validación de la instalación overlay (V0.9)

**Files:**
- Create: `distro/tests/vm-overlay.sh`
- Modify: `README.md`

**Interfaces:**
- Consumes: packages de Tasks 2–7.
- Produces: informe `distro/tests/results/overlay-<fecha>.md`.

- [ ] **Step 1: Test de aceptación**

En Ubuntu 26.04 limpio (VM), añadir repo, `apt install mytical-desktop`, ejecutar `mytical-nix-bootstrap`, `mytical-welcome`; reiniciar; comprobar SDDM única, login Hyprland, red/audio/keyring/Thunar.

- [ ] **Step 2: Verificar fallo**

Run: `bash distro/tests/vm-overlay.sh`
Expected: FAIL si falta cualquier criterio.

- [ ] **Step 3: Implementar el runner**

El script usa SSH a una VM desechable, guarda `journalctl`, `systemctl status`, `ls /usr/share/wayland-sessions` y una captura opcional; no ejecuta en la máquina de desarrollo.

- [ ] **Step 4: Verificar**

Run: `bash distro/tests/vm-overlay.sh`
Expected: PASS y resultados guardados.

- [ ] **Step 5: Commit**

```bash
git add distro/tests/vm-overlay.sh README.md
git commit -m "test(distro): validacion de overlay en VM"
```

### Task 9: ISO V1.1 con remaster casper

La ISO instala la variante APT del escritorio (`hyprland`, `waybar`, `dunst`, etc. desde archive/repo Mytical); no reutiliza el perfil Nix de la Preview. El paquete `mytical-session` elige el wrapper APT.

**Files:**
- Create: `distro/iso/remaster/`, `package-lists/`, `hooks/`
- Create: `distro/iso/Makefile`
- Create: `distro/tests/test_iso_boot.sh`

**Interfaces:**
- Consumes: ISO oficial Ubuntu 26.04, repo APT local, paquetes `mytical-*`; **no** el cierre Nix.
- Produces: `distro/iso/build/mytical-26.04-amd64.iso` + `.sha256` + `.sig`.

- [ ] **Step 1: Test de arranque**

`qemu-system-x86_64 -m 4G -enable-kvm -cdrom ... -boot d -nographic` (o VNC) arranca la ISO y llega a SDDM/live.

- [ ] **Step 2: Verificar fallo**

Run: `bash distro/tests/test_iso_boot.sh`
Expected: FAIL sin ISO.

- [ ] **Step 3: Implementar**

Remasterizar la ISO oficial con casper: extraer squashfs, chroot, añadir repo Mytical y paquetes, ejecutar hooks de branding, limpiar, mksquashfs y xorriso. Reutilizar kernel/initramfs/shim/GRUB de Ubuntu para Secure Boot. Sin `/nix` en el squashfs. Desactivar GNOME/GDM en la lista.

- [ ] **Step 4: Verificar**

Run: `make -C distro/iso iso && bash distro/tests/test_iso_boot.sh`
Expected: ISO arranca y `sha256sum -c` pasa.

- [ ] **Step 5: Commit**

```bash
git add distro/iso distro/tests/test_iso_boot.sh
git commit -m "feat(iso): imagen live-build mytical"
```

### Task 10: Instalador Calamares

**Files:**
- Create: `distro/installer/calamares/` (settings, branding, modules)
- Create: `distro/installer/post-install.sh`
- Create: `distro/tests/test_install_qemu.sh`

**Interfaces:**
- Consumes: ISO de Task 9.
- Produces: instalación automática en QEMU con disco virtio, usuario `test`, SDDM activo y sesión única.

- [ ] **Step 1: Test de instalación**

QEMU con ISO + disco; Calamares en modo no interactivo (`-c`/autoinstall) instala; arrancar disco y comprobar `sddm`, sesión única y `apt`/`nix`.

- [ ] **Step 2: Verificar fallo**

Run: `bash distro/tests/test_install_qemu.sh`
Expected: FAIL sin configuración.

- [ ] **Step 3: Implementar**

Configurar Calamares: particionado, usuarios, locale/teclado, paquetes, bootloader, post-instalación. El post-install activa SDDM, desinstala/omite GNOME, configura Nix y deja `/etc/skel`.

- [ ] **Step 4: Verificar**

Run: `bash distro/tests/test_install_qemu.sh`
Expected: PASS; sin `ubuntu.desktop`.

- [ ] **Step 5: Commit**

```bash
git add distro/installer distro/tests/test_install_qemu.sh
git commit -m "feat(installer): calamares para mytical"
```

### Task 11: CI, release, ramas y recuperación

**Files:**
- Create: `.github/workflows/distro.yml`
- Create: `docs/distro/INSTALL.md`, `RECOVERY.md`, `APT-NIX.md`, `RELEASE.md`
- Create: `distro/Makefile`

**Interfaces:**
- Produces: `make -C distro check`, `make -C distro packages`, `make -C distro iso`, `make -C distro release`; artefactos firmados.

- [ ] **Step 1: Test de CI**

En un PR de prueba, el workflow debe ejecutar lint, shellcheck, python, Nix check, build de paquetes y tests de layout; el build de ISO puede ser nightly/self-hosted.

- [ ] **Step 2: Verificar fallo**

Run: `make -C distro check`
Expected: FAIL si falta un target.

- [ ] **Step 3: Implementar**

Añadir jobs; cachear Nix; usar `pbuilder`/contenedor para paquetes; QEMU/KVM solo en runner con KVM. Corregir el job `luacheck` existente (paquete `lua-check` no resuelve en runner actual). Añadir `VERSION`, `CHANGELOG`, tags anotados, `CODEOWNERS`, `mytical-doctor` (autoremove, duplicados, sesión, keyring/portales) y triage de las 9 ramas `feat/*`. Documentar recuperación: TTY, reinstalar SDDM, rollback Nix y reinstalar la sesión stock si se decide conservar un fallback de recuperación.

- [ ] **Step 4: Verificar**

Run: `make -C distro check`
Expected: PASS; workflow verde.

- [ ] **Step 5: Commit**

```bash
git add .github/workflows/distro.yml docs/distro distro/Makefile
git commit -m "ci(distro): build, tests y release"
```

### Task 12: Preparar la interfaz de Jarvis (sin implementarlo)

**Files:**
- Create: `docs/adr/0002-jarvis-interface.md`
- Create: `docs/adr/0003-privacy-and-permissions.md`

**Interfaces:**
- Produces: decisiones sobre D-Bus `org.mytical.Jarvis1`, permisos, auditoría, portales, secretos y modelos locales/nube.

- [ ] **Step 1: Escribir el ADR**

Documentar que Jarvis será un servicio de usuario, sin root por defecto, con acciones declaradas y confirmación para operaciones destructivas; el modelo local será opt-in; no habrá telemetría.

- [ ] **Step 2: Revisar con el usuario**

Preguntar si Jarvis debe ser local-first, híbrido o cloud-first antes de implementar. No escribir código de IA en V1.

- [ ] **Step 3: Commit**

```bash
git add docs/adr/0002-jarvis-interface.md docs/adr/0003-privacy-and-permissions.md
git commit -m "docs(ai): reservar interfaz jarvis para v1"
```

---

## Orden de ejecución y primer corte

1. **V0.9 (overlay instalable):** Tasks 0–8. Es la forma más rápida de validar APT+Nix, SDDM y la sesión única en Ubuntu 26.04 sin construir una ISO.
2. **V1.0 (ISO instalable):** Tasks 9–10, reutilizando exactamente los paquetes de V0.9.
3. **V1.1 (release):** Task 11 + documentación y firma.
4. **Post-V1:** Task 12 y el asistente Jarvis.

No empezar la ISO hasta que `vm-overlay.sh` pase en una VM limpia.

## Riesgos y mitigaciones

| Riesgo | Mitigación |
|---|---|
| Duplicación APT/Nix | `ownership.yaml` + CI que falla con solapamientos |
| Nix closure enorme | medir `nix path-info -S`; cache local y perfil mínimo |
| Calamares/live-build frágil | V0.9 primero; ISO solo tras smoke test |
| NVIDIA/nixGL | matriz de hardware; documentar `nixGLNvidia` |
| Secure Boot | V1 documenta MOK; no prometer soporte universal |
| Marca Ubuntu | aviso de trademark; no usar logos oficiales |
| Autoremove | simulación + paquetes críticos marcados manual |
| Primer login sin red | cierre Nix en ISO y test sin red |

## Criterios de V1 terminada

- `make -C distro check` y `vm-overlay.sh` pasan.
- ISO arranca UEFI/BIOS y Calamares instala.
- SDDM solo Mytical; login Hyprland; logout/reboot limpios.
- APT y Nix actualizan sin duplicar ni romper.
- Keyring, portales, red, audio, Thunar y polkit funcionan.
- Paquetes/ISO firmados; docs de instalación y recuperación.
- Jarvis solo ADR, sin código.
