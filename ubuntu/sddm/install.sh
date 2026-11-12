#!/usr/bin/env bash
# Instala el tema Mytical en SDDM, lo deja como login por defecto y activa el
# watcher que copia el wallpaper actual. Guarda el display-manager anterior.
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
target_user="${MYTICAL_SDDM_USER:-${SUDO_USER:-${USER:-}}}"
mode=install
state_base=/var/lib/mytical/sddm
theme_dir=/usr/share/sddm/themes/mytical
config=/etc/sddm.conf.d/90-mytical.conf

die() { echo "error: $*" >&2; exit 1; }
say() { printf '\n==> %s\n' "$*"; }

while [ "$#" -gt 0 ]; do
    case "$1" in
        --user) [ "$#" -ge 2 ] || die "falta el usuario"; target_user=$2; shift 2 ;;
        --restore) mode=restore; shift ;;
        --dry-run) mode=dry-run; shift ;;
        -h|--help) sed -n '2,12p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
        *) die "opcion desconocida: $1" ;;
    esac
done

[ -n "$target_user" ] && [ "$target_user" != root ] || die "no pude detectar el usuario; usa --user USUARIO"
home=$(getent passwd "$target_user" | cut -d: -f6)
[ -n "$home" ] || die "no existe el usuario $target_user"
state="$home/.local/state/hypr/wallpaper"

if [ "$mode" = dry-run ]; then
    echo "usuario: $target_user ($home)"
    echo "estado:  $state"
    echo "tema:    $theme_dir"
    echo "config:  $config"
    echo "servicio: mytical-sddm-sync.service"
    echo "watcher:  mytical-sddm.path"
    exit 0
fi

[ "$(id -u)" -eq 0 ] || die "ejecutalo con sudo"

if [ "$mode" = restore ]; then
    say "Quitando SDDM Mytical"
    systemctl disable --now mytical-sddm.path mytical-sddm-sync.service 2>/dev/null || true
    rm -f /etc/systemd/system/mytical-sddm-sync.service \
          /etc/systemd/system/mytical-sddm.path \
          /usr/local/bin/mytical-sddm-sync \
          "$config"
    rm -rf "$theme_dir"
    if [ -f "$state_base/default-display-manager.orig" ]; then
        cp -a "$state_base/default-display-manager.orig" /etc/X11/default-display-manager
    fi
    systemctl daemon-reload
    if [ -f "$state_base/display-manager.service.orig" ]; then
        cp -a "$state_base/display-manager.service.orig" /etc/systemd/system/display-manager.service
        systemctl daemon-reload
        systemctl restart display-manager
        echo "Display manager anterior restaurado."
    else
        echo "No hay backup del display manager anterior."
    fi
    echo "Listo; SDDM Mytical eliminado."
    exit 0
fi

say "Instalando tema SDDM Mytical"
command -v sddm >/dev/null || die "SDDM no esta instalado (apt install sddm)"
[ -x /usr/bin/X ] || die "falta Xorg (apt install xserver-xorg)"
install -d -m 755 /usr/local/bin "$state_base" /etc/sddm.conf.d /usr/share/sddm/themes
rm -rf "$theme_dir"
cp -a "$here/theme" "$theme_dir"
chmod -R a+rX "$theme_dir"
install -m 755 "$here/mytical-sddm-sync" /usr/local/bin/mytical-sddm-sync

cat > "$config" <<CONF
[Theme]
Current=mytical

[General]
DisplayServer=x11
CONF

cat > /etc/systemd/system/mytical-sddm-sync.service <<UNIT
[Unit]
Description=Mytical SDDM wallpaper sync

[Service]
Type=oneshot
ExecStart=/usr/local/bin/mytical-sddm-sync --user ${target_user}
UNIT

cat > /etc/systemd/system/mytical-sddm.path <<UNIT
[Unit]
Description=Watch Hyprland wallpaper for Mytical SDDM

[Path]
PathChanged=${state}
Unit=mytical-sddm-sync.service

[Install]
WantedBy=paths.target
UNIT

# El fondo actual, antes de que el greeter arranque.
/usr/local/bin/mytical-sddm-sync --user "$target_user"

systemctl daemon-reload
systemctl enable --now mytical-sddm.path

# SDDM crea su propio alias display-manager.service al habilitarse. Hay que
# guardar y quitar el alias de GDM primero o systemctl se niega.
if [ -L /etc/systemd/system/display-manager.service ] &&
   [ ! -f "$state_base/display-manager.service.orig" ]; then
    cp -a /etc/systemd/system/display-manager.service "$state_base/display-manager.service.orig"
fi
rm -f /etc/systemd/system/display-manager.service
systemctl enable sddm.service
ln -sf /lib/systemd/system/sddm.service /etc/systemd/system/display-manager.service
systemctl disable gdm.service 2>/dev/null || true
if [ -f /etc/X11/default-display-manager ] &&
   [ ! -f "$state_base/default-display-manager.orig" ]; then
    cp -a /etc/X11/default-display-manager "$state_base/default-display-manager.orig"
fi
printf '/usr/bin/sddm\n' > /etc/X11/default-display-manager
systemctl daemon-reload
say "Cambiando el display manager a SDDM"
systemctl restart display-manager

echo
echo "Tema SDDM: $theme_dir"
echo "Fondo:     $theme_dir/Backgrounds/wallpaper"
echo "Config:    $config"
echo "Volver a GDM: sudo $0 --restore"
