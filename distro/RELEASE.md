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

No publicar hasta que `docs/adr/0008-license-pending.md` esté aceptado, el repo
APT tenga clave de producción y `docs/distro/ASSET-LICENSES.md` no tenga P0
abiertos.
