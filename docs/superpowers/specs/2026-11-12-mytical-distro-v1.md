# Mytical 26.04 — Diseño de la primera versión

**Estado:** borrador para revisión
**Base:** Ubuntu 26.04 LTS (`resolute`), x86_64
**Entrega inicial:** overlay instalable; ISO después de validar APT+Nix y la sesión única.
**Objetivo:** convertir el escritorio Hyprland de estos dotfiles en una distribución instalable, con APT para el sistema y Nix para la capa de usuario.

## 1. Visión

Mytical es un remix de Ubuntu que conserva la base, el kernel, los drivers y la seguridad de Ubuntu, pero reemplaza el escritorio GNOME por una sesión Hyprland curada, reproducible y con identidad visual propia.

No es una colección de dotfiles que el usuario instala a mano: es una ISO que arranca en vivo, instala el sistema completo y deja una sesión funcional sin GNOME.

## 2. Principios

1. **APT manda en el sistema.** Kernel, firmware, Xorg/Wayland, SDDM, red, audio, portales, keyring y actualizaciones de seguridad vienen de Ubuntu.
2. **Nix manda en la capa de escritorio y usuario.** Hyprland, Waybar, Quickshell, terminales y utilidades quedan clavados por `flake.lock` y se activan con Home Manager.
3. **Nunca duplicar un paquete entre APT y Nix.** Un binario tiene un solo dueño; el otro gestor no debe pisarlo.
4. **La ISO no depende de la red para lo esencial.** El cierre Nix del escritorio viaja en la imagen; las actualizaciones son explícitas.
5. **Una sola sesión:** SDDM ofrece únicamente Mytical/Hyprland. No se instala GNOME Shell, GDM ni `ubuntu-session`.
6. **Marca y legalidad:** se declara “basada en Ubuntu”, no “Ubuntu oficial”; se respetan las políticas de marca de Canonical y las licencias de fuentes/temas.
7. **La IA no bloquea la V1.** Jarvis tendrá una interfaz reservada, pero no se implementa en la primera versión.

## 3. Arquitectura propuesta

```text
Ubuntu 26.04 base (kernel, firmware, drivers, archive)
        │
        ├── APT: sddm, xorg, network-manager, pipewire, wireplumber,
        │        xdg-desktop-portal-hyprland, portal-gtk, gnome-keyring,
        │        gvfs, polkit, thunar, zsh, direnv, fontconfig, plymouth
        │
        ├── mytical-* (repo APT propio, firmado)
        │     ├── mytical-desktop      metapaquete del sistema
        │     ├── mytical-session      sesión, SDDM, systemd, portal config
        │     ├── mytical-branding     SDDM, Plymouth, wallpapers, os-release
        │     ├── mytical-nix-bootstrap instalador Nix + cache offline
        │     └── mytical-welcome      primer arranque y ajustes
        │
        └── Nix/Home Manager (flake.lock + cache offline)
              Hyprland, Waybar, Quickshell, rofi, dunst, wlogout,
              Alacritty, btop, hyprlock, cliphist, nixGL
```

### 3.1 Separación APT / Nix

| Capa | V1.0 Preview (overlay) | V1.1 ISO (objetivo) |
|---|---|---|
| Kernel, firmware, drivers, arranque | APT | APT |
| Login y sistema | APT (SDDM/Plymouth) | APT (SDDM/Plymouth) |
| Integración | APT (portales, keyring, gvfs, polkit, red, audio) | APT |
| Compositor y escritorio | Nix (Hyprland 0.56) | APT/Mytical repo (Hyprland fijado) |
| Apps de usuario | Nix + APT | APT/Mytical repo; Nix opcional |
| Sesión | wrapper `/usr/bin/mytical-session` | wrapper `/usr/bin/mytical-session` |
| Actualizaciones | APT + `nix flake update` | APT + repo Mytical; Nix opcional |

La V1.0 no intenta meter `/nix` en una ISO. La V1.1 nace de una ISO oficial de Ubuntu (casper) y **no incluye el store Nix en el squashfs**; Nix queda como gestor opcional instalable.

### 3.2 Imagen V1.1

- Remaster de la ISO oficial de Ubuntu 26.04 (casper) en lugar de `live-build`; se reutilizan kernel, initramfs, shim/GRUB firmado y casper.
- Instalador **Calamares** con branding Mytical; el instalador oficial queda como fallback de V1.
- Selección de paquetes desde `distro/iso/package-lists/`; repo Mytical embebido.
- Sin `/nix` en el squashfs; Nix se instala después, opcional, desde paquete/instalador vendorizado.
- Arranque UEFI y BIOS; Secure Boot se hereda de Ubuntu; firma de ISO en release.

### 3.3 Primer arranque

1. Calamares crea usuario, zona horaria, teclado y disco.
2. Post-instalación: APT fija SDDM, sesión Mytical y servicios; no instala GNOME.
3. `mytical-welcome` (primer login) verifica Nix, activa Home Manager, elige wallpaper y explica APT/Nix.
4. El escritorio queda listo sin depender de una descarga de 3–4 GiB en el primer login.

## 4. Alcance de la V1

### Incluido

- **V1.0 Preview (primera entrega):** overlay instalable sobre Ubuntu 26.04, con APT + Nix y sesión Hyprland; es la forma realista de validar todo con lo que ya existe.
- **V1.1 ISO:** remaster de la ISO oficial de Ubuntu 26.04 con casper + Calamares, APT como dueño del escritorio y Nix opcional; no lleva `/nix` en el squashfs.
- SDDM con tema Mytical y fondo dinámico.
- Sesión única Hyprland desde Nix.
- Nix multiusuario + Home Manager con `flake.lock`.
- Wallpaper, Waybar, Quickshell, Alacritty, btop, GTK y paletas dinámicas actuales.
- Thunar, red, audio, Bluetooth básico, portales, keyring y polkit.
- `hypridle`, `hyprshot`, visor de imágenes/PDF, comprimidos, editor y terminal tematizada.
- Primer arranque con cuenta, TZ, teclado, idioma, wallpaper, Nix y actualizaciones.
- Repo APT local firmado con paquetes `mytical-*`.
- Documentación de instalación, recuperación y rollback.
- CI mínimo y pruebas de humo en VM.

### Fuera de la V1

- Asistente Jarvis funcional (solo interfaz/ADR).
- Tienda de aplicaciones propia.
- Actualizaciones delta de ISO.
- Soporte oficial de NVIDIA/Secure Boot más allá de lo documentado.
- Múltiples ediciones de escritorio.
- Telemetría o cuenta en la nube.

## 5. Hallazgos del análisis que condicionan la V1

- `setup.py` no enlaza todo lo que ejecuta la sesión (`session-start`, `session-splash`, `gtk-theme`, `btop-theme`); la vía sin Nix arranca sin barra/fondo. Debe corregirse o retirarse antes de empaquetar.
- `mkOutOfStoreSymlink` deja `~/.config` apuntando al checkout Git; una ISO no puede depender de una rama activa. La imagen debe copiar configuración inmutable o empaquetarla.
- No hay `LICENSE` raíz, `THIRD_PARTY_NOTICES` ni tests de `utils.py`/`check-config.py`; el tema SDDM es GPL, Audiowide OFL y la animación deriva de CachyOS.
- `graphify-out/` está versionado, `docs/` no, y hay 9 ramas `feat/*` sin política de release.
- `packages/ubuntu.txt` es de 24.04 y depende de PPAs de terceros; una distro no debe depender de un PPA para su escritorio.
- El cierre Nix actual ronda 3,8 GiB; incluirlo en la ISO exige presupuesto de tamaño o un perfil más pequeño. Si no cabe en el presupuesto, la V1 se entrega primero como overlay instalable y la ISO se pospone.
- La ISO no debe instalar `setup.py` ni permitir tres dueños de `~/.config`: APT/instalador es dueño en la imagen; Home Manager solo en la vía de desarrollo.
- `nix/home.nix` es un perfil de usuario, no una capa de distro: usa `mkOutOfStoreSymlink`, `--impure`, un `link` al checkout y scripts con `sudo`. Para producción hace falta una salida pura, configuración inmutable y módulos separados.
- Hyprland y `xdg-desktop-portal-hyprland` deben formar un par probado. Un solo dueño del compositor; no conviene mantener Hyprland de APT y de Nix a la vez.
- `hyprshot` no lo aporta ninguna vía y `SUPER+O` falla en una instalación limpia. Empaquetarlo o reescribir el atajo con `grim`/`slurp`.
- Hay duplicados funcionales: kitty/Alacritty, zsh de login de Nix vs sistema, dos terminales, dos fuentes JetBrains, `pulseaudio`/`wireplumber` de Nix. La V1 debe elegir uno por función.
- El cierre Nix son ~3,8 GiB y `nix flake archive` también debe incluir las fuentes de los inputs; sin eso no hay primer login offline.
- La identidad está partida en tres: Plymouth azul CachyOS, SDDM/paleta dinámica y escritorio; rofi, dunst y kitty no siguen la paleta. Falta una fuente única de branding y una sola capa de paleta.
- Faltan `hypridle` (bloqueo por inactividad), `hyprshot` (atajo MOD+O), apps base (imágenes, PDF, comprimidos, editor), asociaciones MIME y navegador por defecto.
- No hay unidades systemd de usuario: waybar/dunst/awww/cliphist se lanzan con `&` sin supervisión ni orden de arranque.
- El greeter no debe leer `/home`: wallpaper y paleta deben publicarse en `/var/lib/mytical` mediante un helper root-owned y polkit.
- Wallpapers, iconos de wlogout y arte CachyOS no tienen procedencia/licencia documentada; hay que auditarlos antes de la ISO.

## 6. Decisiones aprobadas

1. **Overlay primero, ISO después.** V1.0 es instalable sobre Ubuntu 26.04; V1.1 es la ISO.
2. **APT/version propia posee el escritorio de la ISO.** En Preview se conserva Nix; en ISO Hyprland/Waybar salen del archive o de un paquete Mytical fijado.
3. **Kitty es el terminal por defecto.** Alacritty queda opcional/fuera de V1.
4. **Nix estable 26.05.** `nixpkgs` en `nixos-26.05` y Home Manager en `release-26.05`.
5. **Jarvis híbrido local-first.** Si no puede ejecutar local, puede usar un proveedor cloud con consentimiento explícito, por petición y con auditoría.
6. **Una sola sesión Hyprland** con wrapper `/usr/bin/mytical-session`; sin GNOME/Ubuntu session.
7. **Documentar cada decisión** en `docs/adr/` y cada release con manifiesto/checksum.

## 7. Riesgos principales

- **Duplicación APT/Nix** de Hyprland, Waybar, Alacritty, fuentes y temas: debe resolverse antes de la ISO.
- **Cierre Nix grande** (varios GiB) y tiempos de arranque del live.
- **Calamares + live-build** tienen más piezas móviles que un simple script; presupuestar iteraciones.
- **NVIDIA/nixGL** y Secure Boot son los fallos de hardware más probables.
- **Marca Ubuntu**: revisar trademark policy antes de publicar; no usar logos oficiales.
- **Licencias**: Audiowide (OFL), animación CachyOS, wallpapers; incluir avisos.
- **Autoremove** puede llevarse piezas base; fijar paquetes críticos y probar actualizaciones.

## 8. Criterios de aceptación de la V1

**V1.0 Preview**
- Overlay instala `mytical-desktop` + Nix/Home Manager en Ubuntu 26.04 limpio.
- SDDM solo muestra **Mytical**; no hay sesión Ubuntu/GNOME.
- Primer login entra a Hyprland con Waybar, wallpaper y paletas correctas.
- Red, audio, teclado, portales, keyring, Thunar y polkit funcionan.
- `apt update && apt upgrade` no rompe el escritorio; `--rollback` de Nix funciona.

**V1.1 ISO**
- La ISO arranca en QEMU UEFI y BIOS.
- Calamares instala sin red y deja SDDM.
- No hay `/nix` en el squashfs; Nix es opcional.
- `apt update && apt upgrade` no rompe el escritorio.
- Logout, reboot y shutdown no dejan pantalla negra permanente.
- La ISO y los paquetes están firmados y tienen checksum.
- Documentación de instalación, recuperación y vuelta a Ubuntu disponible.
