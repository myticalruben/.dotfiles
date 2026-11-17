# Release V1.0 Preview

## Construir

```sh
make -C distro clean packages
make -C distro test
```

## Instalar

```sh
sudo distro/install-overlay.sh --user "$USER"
```

El instalador no ejecuta `autoremove` ni cambia el display manager.
Después, como usuario:

```sh
cd ~/.dotfiles
nix run .#home-manager -- switch --flake .#default --impure -b backup
mytical-welcome
```

## Verificar

```sh
systemctl is-active sddm
ls /usr/share/wayland-sessions
dpkg -s mytical-session mytical-desktop mytical-welcome
nix flake check --no-build
mytical-welcome --check
```

## Publicación

La licencia raíz ya está aceptada (GPL-3.0-or-later). Antes de publicar faltan
la clave APT de producción y la revisión final de assets.
