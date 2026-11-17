#!/usr/bin/env bash
# Instala el overlay Mytical V1.0 sobre Ubuntu 26.04.
# No ejecuta autoremove ni cambia el display manager: mytical-session ya se
# registra en SDDM. El perfil Nix se activa aparte con home-manager.
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
build="${MYTICAL_BUILD_DIR:-$here/build}"
user="${SUDO_USER:-}"
mode=install

die() { echo "error: $*" >&2; exit 1; }
say() { printf '\n==> %s\n' "$*"; }

while [ "$#" -gt 0 ]; do
    case "$1" in
        --user) [ "$#" -ge 2 ] || die "falta el usuario"; user=$2; shift 2 ;;
        --build-dir) [ "$#" -ge 2 ] || die "falta el directorio"; build=$2; shift 2 ;;
        --dry-run) mode=dry-run; shift ;;
        -h|--help) sed -n '2,10p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
        *) die "opcion desconocida: $1" ;;
    esac
done

[ -n "$user" ] && [ "$user" != root ] || die "usa --user USUARIO"

. /etc/os-release
[ "${ID:-}" = ubuntu ] || die "este overlay asume Ubuntu"
[ "${VERSION_ID:-}" = "26.04" ] || die "este overlay asume Ubuntu 26.04 (encontrado ${VERSION_ID:-?})"

packages=(mytical-session mytical-welcome mytical-desktop)
for package in "${packages[@]}"; do
    deb=$(find "$build" -maxdepth 1 -name "${package}_*.deb" -print -quit)
    [ -n "$deb" ] || die "falta el .deb de $package en $build"
done

if [ "$mode" = dry-run ]; then
    echo "usuario: $user"
    echo "build:   $build"
    for package in "${packages[@]}"; do
        echo "paquete: $(find "$build" -maxdepth 1 -name "${package}_*.deb" -print -quit)"
    done
    echo "Nix:     se comprueba después; no se instala sin red"
    exit 0
fi

[ "$(id -u)" -eq 0 ] || die "ejecutalo con sudo"

say "Instalando paquetes del overlay"
for package in "${packages[@]}"; do
    deb=$(find "$build" -maxdepth 1 -name "${package}_*.deb" -print -quit)
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends "$deb"
done

# El paquete zsh puede preguntar por /etc/zsh/zshrc en una instalación previa.
DEBIAN_FRONTEND=noninteractive dpkg --force-confold --configure -a

home=$(getent passwd "$user" | cut -d: -f6)
say "Comprobando Nix y Home Manager para $user"
if [ -x "$home/.nix-profile/bin/home-manager" ]; then
    echo "Home Manager presente; activá el perfil con:"
    echo "  cd $home/.dotfiles && nix run .#home-manager -- switch --flake .#default --impure -b backup"
else
    echo "Nix/Home Manager no están instalados todavía."
    echo "Ejecutá como $user: bash $home/.dotfiles/nix/setup/bootstrap.sh"
fi

echo
echo "Overlay instalado. SDDM leerá /usr/share/wayland-sessions/mytical.desktop."
echo "Primer arranque: mytical-welcome"
