# SDDM neon para Ubuntu

Login SDDM con el wallpaper actual de Hyprland y un tema neon basado en
[SDDM Astronaut](https://github.com/Keyitdev/sddm-astronaut-theme) (GPL-3.0).

## Dependencias

```sh
sudo apt install sddm xserver-xorg
```

## Instalar

```sh
sudo ubuntu/sddm/install.sh --user deepseek
```

El instalador:

- Copia el tema a `/usr/share/sddm/themes/mytical`.
- Deja `Current=mytical` en `/etc/sddm.conf.d/90-mytical.conf`.
- Copia el wallpaper actual a `Backgrounds/wallpaper`.
- Activa `mytical-sddm.path` para seguirlo cuando cambie en Hyprland.
- Cambia el display manager de GDM a SDDM y guarda el anterior.

No reinicia la sesion de Hyprland: el proximo greeter de SDDM ya usa el tema.

## Volver a GDM

```sh
sudo ubuntu/sddm/install.sh --restore
```

## Notas

- SDDM se configura en X11 porque el servidor Wayland de GDM no viene con
  Xorg en esta instalacion.
- El fondo se actualiza al cambiar `~/.local/state/hypr/wallpaper`; el greeter
  lo toma en el proximo inicio de sesion.
