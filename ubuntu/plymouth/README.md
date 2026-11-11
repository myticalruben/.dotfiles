# Plymouth Mytical (Ubuntu)

Tema de arranque y apagado para Ubuntu. Usa el modulo `two-step`:

- `animation-*.png` / `throbber-*.png`: wordmark Mytical y tres puntos neon.
- `shutdown-animation-*.png`: la pantalla se agrieta y se oscurece al apagar/reiniciar.

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
