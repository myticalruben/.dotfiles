#!/usr/bin/env bash
set -euo pipefail
root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
deb="$root/distro/build/mytical-session_0.1.0-1~resolute1_all.deb"
[ -f "$deb" ] || { echo "falta $deb; ejecuta make -C distro packages" >&2; exit 1; }
dpkg-deb -c "$deb" | grep -q usr/share/wayland-sessions/mytical.desktop
dpkg-deb -c "$deb" | grep -q usr/bin/mytical-session
depends="$(dpkg-deb -f "$deb" Depends)"
printf '%s\n' "$depends" | grep -q sddm
printf '%s\n' "$depends" | grep -q gnome-keyring
if printf '%s\n' "$depends" | grep -Eq 'gnome-shell|ubuntu-session|gdm3'; then
    echo "dependencia GNOME prohibida" >&2; exit 1
fi
echo "OK: paquete mytical-session"
[ -f "$root/distro/build/mytical-welcome_0.1.0-1~resolute1_all.deb" ] || { echo "falta mytical-welcome" >&2; exit 1; }
dpkg-deb -c "$root/distro/build/mytical-welcome_0.1.0-1~resolute1_all.deb" | grep -q usr/bin/mytical-welcome
echo "OK: paquete mytical-welcome"
theme_deb="$root/distro/build/mytical-sddm-theme_0.1.0-1~resolute1_all.deb"
[ -f "$theme_deb" ] || { echo "falta mytical-sddm-theme" >&2; exit 1; }
dpkg-deb -c "$theme_deb" | grep -q usr/share/sddm/themes/mytical/Main.qml
dpkg-deb -c "$theme_deb" | grep -q usr/share/sddm/themes/mytical/Backgrounds/wallpaper
echo "OK: paquete mytical-sddm-theme"
