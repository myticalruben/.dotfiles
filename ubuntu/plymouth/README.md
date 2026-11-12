# Plymouth Mytical (Ubuntu)

Tema de arranque para Ubuntu con la entrada de particulas azules estilo
CachyOS, pero con el wordmark **MYTICAL** en vez de su logo
(https://github.com/CachyOS/plymouth-theme). Usa el modulo `two-step`:

- `animation-*.png`: MYTICAL que se arma y se desintegra en particulas azules.
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
