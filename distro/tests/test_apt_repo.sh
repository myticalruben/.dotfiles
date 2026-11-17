#!/usr/bin/env bash
# Prueba end-to-end del repo APT de Mytical.
#
# - construye distro/apt/public/ con apt-ftparchive
# - firma con una clave GPG efímera (sin passphrase) si hay gpg/gpgv
# - sirve el repo con python3 -m http.server en 127.0.0.1:<puerto libre>
# - hace apt-get update en un root temporal; NO toca el APT del host
# - comprueba que mytical-session aparece y que su .deb se descarga
#
# Códigos: 0 OK, 77 SKIP (falta una herramienta imprescindible), otro = fallo.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
APT_DIR="$REPO_ROOT/distro/apt"
PUBLIC="$APT_DIR/public"
BUILD_DIR="$REPO_ROOT/distro/build"

log()  { printf '\n==> %s\n' "$*"; }
skip() { printf 'SKIP: %s\n' "$*" >&2; }
die()  { printf 'ERROR: %s\n' "$*" >&2; exit 1; }

require() {
    command -v "$1" >/dev/null 2>&1 || {
        skip "falta $1 ($2)"
        exit 77
    }
}

# GnuPG no está en el PATH de este entorno Debian 13, pero sí en /nix/store.
# En Ubuntu 26.04 basta con `sudo apt install gnupg`.
find_gpg() {
    if command -v gpg >/dev/null 2>&1 && command -v gpgv >/dev/null 2>&1; then
        return 0
    fi
    local dir
    for dir in /nix/store/*-gnupg-*/bin; do
        [ -x "$dir/gpg" ] && [ -x "$dir/gpgv" ] || continue
        PATH="$dir:$PATH"
        export PATH
        log "GnuPG del sistema ausente; usando $dir"
        return 0
    done
    return 1
}

require apt-ftparchive "Ubuntu: sudo apt install apt-utils"
require dpkg-deb      "Ubuntu: sudo apt install dpkg"
require apt-get       "Ubuntu: sudo apt install apt"
require apt-cache     "Ubuntu: sudo apt install apt"
require python3       "necesario para el servidor HTTP de la prueba"
require gzip          "necesario para Packages.gz"
require make          "Ubuntu: sudo apt install make"

tmp="$(mktemp -d "${TMPDIR:-/tmp}/mytical-apt-test.XXXXXX")"
chmod 755 "$tmp"
server_pid=""
cleanup() {
    local status=$?
    if [ -n "$server_pid" ]; then
        kill "$server_pid" 2>/dev/null || true
        wait "$server_pid" 2>/dev/null || true
    fi
    rm -rf "$tmp"
    exit "$status"
}
trap cleanup EXIT

log "1/7 paquetes"
shopt -s nullglob
debs=( "$BUILD_DIR"/*.deb )
shopt -u nullglob
if [ "${#debs[@]}" -eq 0 ]; then
    log "no hay .deb; ejecutando make -C distro packages"
    make -C "$REPO_ROOT/distro" packages
fi
shopt -s nullglob
session_debs=( "$BUILD_DIR"/mytical-session_*.deb )
shopt -u nullglob
[ "${#session_debs[@]}" -ge 1 ] \
    || die "no se generó mytical-session en $BUILD_DIR"

log "2/7 clave GPG efímera"
signed=0
if find_gpg; then
    signed=1
    export GNUPGHOME="$tmp/gnupg"
    mkdir -m 700 "$GNUPGHOME"
    # Clave de un día, sin passphrase: el test nunca pide ni usa secretos.
    gpg --batch --yes --no-tty --pinentry-mode loopback --passphrase '' \
        --quick-generate-key "Mytical APT Test <apt-test@mytical.invalid>" \
        rsa3072 sign 1d >/dev/null 2>&1
    fpr="$(gpg --batch --with-colons --list-keys 2>/dev/null \
        | awk -F: '/^fpr:/{print $10; exit}')"
    [ -n "$fpr" ] || die "no se pudo obtener el fingerprint de la clave efímera"
    mkdir -p "$tmp/apt-root/etc/apt/keyrings"
    gpg --batch --export "$fpr" > "$tmp/apt-root/etc/apt/keyrings/mytical-apt.gpg" 2>/dev/null
    [ -s "$tmp/apt-root/etc/apt/keyrings/mytical-apt.gpg" ] \
        || die "no se pudo exportar la clave pública efímera"
    printf 'clave efímera %s (1 día, sin passphrase)\n' "$fpr"
else
    skip "gpg/gpgv no disponibles: se prueba el repo sin firmar (Trusted: yes)"
fi

log "3/7 repo y firma"
make -C "$APT_DIR" clean >/dev/null
if [ "$signed" -eq 1 ]; then
    make -C "$APT_DIR" sign GPG_KEY="$fpr"
else
    make -C "$APT_DIR" repo
fi

for f in \
    "$PUBLIC/dists/mytical/Release" \
    "$PUBLIC/dists/mytical/main/binary-amd64/Packages" \
    "$PUBLIC/dists/mytical/main/binary-amd64/Packages.gz"
do
    [ -s "$f" ] || die "falta $f"
done
gzip -dc "$PUBLIC/dists/mytical/main/binary-amd64/Packages.gz" \
    | cmp -s - "$PUBLIC/dists/mytical/main/binary-amd64/Packages" \
    || die "Packages.gz no coincide con Packages"
gzip -dc "$PUBLIC/dists/mytical/main/binary-amd64/Packages.gz" \
    | grep -qx 'Package: mytical-session' \
    || die "mytical-session no está en Packages"

if [ "$signed" -eq 1 ]; then
    for f in "$PUBLIC/dists/mytical/InRelease" "$PUBLIC/dists/mytical/Release.gpg"; do
        [ -s "$f" ] || die "falta $f"
    done
    gpg --batch --verify "$PUBLIC/dists/mytical/InRelease" \
        >"$tmp/verify-inrelease.log" 2>&1 \
        || { cat "$tmp/verify-inrelease.log" >&2; die "InRelease no verifica"; }
    gpg --batch --verify "$PUBLIC/dists/mytical/Release.gpg" \
        "$PUBLIC/dists/mytical/Release" >/dev/null 2>&1 \
        || die "Release.gpg no verifica"
    printf 'firma OpenPGP correcta\n'
fi

log "4/7 servidor HTTP"
port="$(python3 - <<'PY'
import socket
s = socket.socket()
s.bind(("127.0.0.1", 0))
print(s.getsockname()[1])
s.close()
PY
)"
python3 -m http.server "$port" --bind 127.0.0.1 --directory "$PUBLIC" \
    >"$tmp/http.log" 2>&1 &
server_pid=$!

port_open() {
    python3 - "$1" <<'PY'
import socket, sys
s = socket.socket()
s.settimeout(0.2)
try:
    s.connect(("127.0.0.1", int(sys.argv[1])))
except OSError:
    sys.exit(1)
finally:
    s.close()
PY
}

ready=0
for _ in $(seq 1 100); do
    if port_open "$port"; then ready=1; break; fi
    sleep 0.05
done
[ "$ready" -eq 1 ] || { cat "$tmp/http.log" >&2; die "el servidor HTTP no responde"; }
printf 'sirviendo %s en http://127.0.0.1:%s\n' "$PUBLIC" "$port"

log "5/7 root APT temporal"
root="$tmp/apt-root"
mkdir -p \
    "$root/etc/apt/sources.list.d" \
    "$root/etc/apt/apt.conf.d" \
    "$root/etc/apt/preferences.d" \
    "$root/etc/apt/trusted.gpg.d" \
    "$root/var/lib/apt/lists/partial" \
    "$root/var/cache/apt/archives/partial" \
    "$root/var/lib/dpkg" \
    "$root/var/log/apt"
: > "$root/etc/apt/apt.conf"
: > "$root/etc/apt/sources.list"
: > "$root/etc/apt/preferences"
: > "$root/var/lib/dpkg/status"

{
    echo "Types: deb"
    echo "URIs: http://127.0.0.1:$port"
    echo "Suites: mytical"
    echo "Components: main"
    echo "Architectures: amd64"
    if [ "$signed" -eq 1 ]; then
        echo "Signed-By: $root/etc/apt/keyrings/mytical-apt.gpg"
    else
        echo "Trusted: yes"
    fi
} > "$root/etc/apt/sources.list.d/mytical.sources"

apt_opts=(
    -o "Dir=$root"
    -o "Dir::Etc::main=$root/etc/apt/apt.conf"
    -o "Dir::Etc::parts=$root/etc/apt/apt.conf.d"
    -o "Dir::Etc::sourcelist=$root/etc/apt/sources.list"
    -o "Dir::Etc::sourceparts=$root/etc/apt/sources.list.d"
    -o "Dir::Etc::preferences=$root/etc/apt/preferences"
    -o "Dir::Etc::preferencesparts=$root/etc/apt/preferences.d"
    -o "Dir::Etc::trusted=/dev/null"
    -o "Dir::Etc::trustedparts=$root/etc/apt/trusted.gpg.d"
    -o "Dir::State::status=$root/var/lib/dpkg/status"
    -o "Dir::State::lists=$root/var/lib/apt/lists"
    -o "Dir::Cache=$root/var/cache/apt"
    -o "Dir::Log=$root/var/log/apt"
    -o "APT::Architecture=amd64"
    -o "APT::Sandbox::User=$(id -un)"
    -o "APT::Get::List-Cleanup=0"
    -o "Acquire::Retries=0"
    -o "Acquire::http::Proxy=false"
)

log "6/7 apt-get update aislado"
if ! apt-get "${apt_opts[@]}" update 2>&1 | tee "$tmp/apt-update.log"; then
    die "apt-get update falló"
fi

show="$(apt-cache "${apt_opts[@]}" show mytical-session)"
printf '%s\n' "$show" | grep -qx 'Package: mytical-session' \
    || die "apt-cache no ve mytical-session"
policy="$(apt-cache "${apt_opts[@]}" policy mytical-session)"
printf '%s\n' "$policy" | grep -Fq "http://127.0.0.1:${port} mytical/main amd64 Packages" \
    || die "el paquete no viene del repo de prueba"
printf '%s\n' "$policy" | grep -q 'Candidate: [0-9]' \
    || die "mytical-session no tiene candidato instalable"
printf '%s\n' "$show" | sed -n '1,8p'

log "7/7 descarga del .deb"
mkdir -p "$tmp/download"
( cd "$tmp/download" && apt-get "${apt_opts[@]}" download mytical-session ) \
    >"$tmp/apt-download.log" 2>&1 \
    || { cat "$tmp/apt-download.log" >&2; die "apt-get download falló"; }
shopt -s nullglob
downloaded=( "$tmp/download"/mytical-session_*.deb )
shopt -u nullglob
[ "${#downloaded[@]}" -eq 1 ] || die "apt-get download no produjo un único .deb"
source_deb="$BUILD_DIR/$(basename "${downloaded[0]}")"
[ -f "$source_deb" ] || die "el .deb descargado no corresponde a $BUILD_DIR"
cmp -s "${downloaded[0]}" "$source_deb" \
    || die "el .deb descargado difiere del generado por make packages"

printf '\nOK: apt-get update contra %s resolvió mytical-session y descargó %s\n' \
    "http://127.0.0.1:$port" "$(basename "${downloaded[0]}")"
if [ "$signed" -eq 0 ]; then
    skip "la firma GPG no se pudo probar en este entorno (repo servido con Trusted: yes)"
fi
