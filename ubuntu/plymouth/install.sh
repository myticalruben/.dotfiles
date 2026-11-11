#!/usr/bin/env bash
# Instala el tema Plymouth "Mytical" en Ubuntu y lo deja por defecto.
#
# Uso:
#   sudo ubuntu/plymouth/install.sh           # instala y actualiza initramfs
#   sudo ubuntu/plymouth/install.sh --dry-run # solo muestra lo que haria
#   sudo ubuntu/plymouth/install.sh --restore # vuelve al tema anterior
#
# El cambio se ve al reiniciar. Se guarda una copia del initrd actual y del
# tema anterior en /var/lib/mytical-plymouth/ para poder revertir.
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
src="$here/mytical"
theme_dir=/usr/share/plymouth/themes/mytical
alt=/usr/share/plymouth/themes/default.plymouth
state=/var/lib/mytical-plymouth
backup=/var/backups

die() { echo "error: $*" >&2; exit 1; }
say() { printf '\n==> %s\n' "$*"; }

dry_run=0
restore=0
for arg in "$@"; do
    case "$arg" in
        --dry-run) dry_run=1 ;;
        --restore) restore=1 ;;
        -h|--help)
            sed -n '2,16p' "$0" | sed 's/^# \{0,1\}//'
            exit 0 ;;
        *) die "opcion desconocida: $arg" ;;
    esac
done

[ -d "$src" ] || die "no existe $src"
[ -f "$src/mytical.plymouth" ] || die "falta mytical.plymouth"

if [ "$restore" = 1 ]; then
    [ -f "$state/previous" ] || die "no hay tema anterior guardado en $state"
    previous="$(cat "$state/previous")"
    [ -f "/usr/share/plymouth/themes/$previous/$previous.plymouth" ] ||
        die "el tema anterior '$previous' ya no existe"
    say "Restaurando Plymouth a '$previous'"
    if [ "$dry_run" = 1 ]; then
        echo "update-alternatives --set default.plymouth /usr/share/plymouth/themes/$previous/$previous.plymouth"
        echo "update-initramfs -u -k all"
        exit 0
    fi
    [ "$(id -u)" -eq 0 ] || die "ejecutalo con sudo"
    update-alternatives --set default.plymouth "/usr/share/plymouth/themes/$previous/$previous.plymouth"
    update-initramfs -u -k all
    echo "Listo; reinicia para ver el tema anterior."
    exit 0
fi

if [ "$dry_run" = 1 ]; then
    echo "origen : $src"
    echo "destino: $theme_dir"
    echo "alternativa: $alt"
    echo "initramfs: update-initramfs -u -k all"
    exit 0
fi

[ "$(id -u)" -eq 0 ] || die "ejecutalo con sudo"
command -v update-alternatives >/dev/null || die "falta update-alternatives"
command -v update-initramfs >/dev/null || die "falta update-initramfs"

mkdir -p "$state" "$backup"
current="$(basename "$(readlink -f /etc/alternatives/default.plymouth 2>/dev/null || true)" .plymouth)"
if [ -n "$current" ] && [ "$current" != "mytical" ]; then
    printf '%s\n' "$current" > "$state/previous"
    echo "Tema anterior: $current"
fi
if [ ! -f "$state/previous" ]; then
    echo "bgrt" > "$state/previous"
fi

initrd="/boot/initrd.img-$(uname -r)"
if [ -f "$initrd" ] && [ ! -f "$state/initrd-$(basename "$initrd").backup" ]; then
    cp -a "$initrd" "$state/initrd-$(basename "$initrd").backup"
    echo "Initrd de respaldo: $state/initrd-$(basename "$initrd").backup"
fi

say "Instalando tema Mytical"
rm -rf "$theme_dir"
install -d "$theme_dir"
cp -a "$src/." "$theme_dir/"
chown -R root:root "$theme_dir"

# El módulo two-step usa estos PNG para los dialogos de contraseña/teclado.
for f in entry.png bullet.png keyboard.png lock.png capslock.png keymap-render.png; do
    if [ ! -f "$theme_dir/$f" ] && [ -f "/usr/share/plymouth/themes/spinner/$f" ]; then
        cp -a "/usr/share/plymouth/themes/spinner/$f" "$theme_dir/$f"
    fi
done

say "Registrando tema por defecto"
update-alternatives --install "$alt" default.plymouth "$theme_dir/mytical.plymouth" 200
update-alternatives --set default.plymouth "$theme_dir/mytical.plymouth"

say "Regenerando initramfs"
update-initramfs -u -k all

echo
echo "Tema instalado: $(readlink -f /etc/alternatives/default.plymouth)"
echo "Reinicia para verlo. Para volver atras: sudo $0 --restore"
