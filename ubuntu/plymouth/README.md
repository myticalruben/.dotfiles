# Plymouth Mytical (Ubuntu)

Tema de arranque para Ubuntu con el estilo visual del logo de CachyOS:
wordmark **MYTICAL** en 3D, degradado azul, bisel y extrusion
(https://github.com/CachyOS/plymouth-theme). Usa el modulo `two-step`:

- `animation-*.png`: MYTICAL 3D en azul que se arma y se desintegra.
- `fonts/Audiowide-Regular.ttf`: tipografia geometrica usada para generar el wordmark (OFL).
- `throbber-*.png`: el throbber azul de CachyOS.
- Sin animacion propia de apagado; se deja el comportamiento de CachyOS.

## Instalar

```sh
sudo ubuntu/plymouth/install.sh
```

Reinicia para verlo. El script guarda el initrd y el tema anterior en
`/var/lib/mytical-plymouth/`.

## Volver atras

```sh
sudo ubuntu/plymouth/install.sh --restore
```

## Solo mirar lo que haria

```sh
ubuntu/plymouth/install.sh --dry-run
```
