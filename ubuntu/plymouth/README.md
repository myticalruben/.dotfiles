# Plymouth Mytical (Ubuntu)

Tema de arranque para Ubuntu basado en la animacion de CachyOS
(https://github.com/CachyOS/plymouth-theme). Usa el modulo `two-step`:

- `animation-*.png` / `throbber-*.png`: la animacion azul de CachyOS.
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
