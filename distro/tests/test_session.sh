#!/usr/bin/env bash
# Construye los paquetes de la sesión/escritorio Mytical y verifica lo que
# realmente queda dentro del .deb: wrapper, .desktop, conffile de SDDM,
# scripts de mantenimiento y ausencia de sesiones GNOME/Ubuntu.
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
build_dir="$root/build"
tmp_dir=""

cleanup() {
    if [ -n "$tmp_dir" ] && [ -d "$tmp_dir" ]; then
        rm -rf -- "$tmp_dir"
    fi
}
trap cleanup EXIT

fail() {
    printf 'FAIL: %s\n' "$*" >&2
    exit 1
}

skip() {
    printf 'SKIP: %s\n' "$*"
    exit 0
}

if ! command -v dpkg-deb >/dev/null 2>&1; then
    skip "dpkg-deb no está disponible; no se construyen ni verifican paquetes"
fi

build_pkg() {
    local pkg="$1" version deb
    version="$(sed -n 's/^Version: //p' "$root/debian/$pkg/DEBIAN/control")"
    [ -n "$version" ] || fail "sin Version en debian/$pkg/DEBIAN/control"
    mkdir -p "$build_dir"
    deb="$build_dir/${pkg}_${version}_all.deb"
    dpkg-deb --build --root-owner-group "$root/debian/$pkg" "$deb" >/dev/null ||
        fail "no se pudo construir $pkg"
    printf '%s\n' "$deb"
}

expect_line() {
    local file="$1" line="$2" what="$3"
    grep -qxF -- "$line" "$file" ||
        fail "$what: falta '$line' en ${file#"$tmp_dir"/}"
}

session_deb="$(build_pkg mytical-session)"
desktop_deb="$(build_pkg mytical-desktop)"
for deb in "$session_deb" "$desktop_deb"; do
    [ -f "$deb" ] || fail "no se generó ${deb#"$root"/}"
done
printf 'construidos: %s y %s\n' \
    "${session_deb#"$root"/}" "${desktop_deb#"$root"/}"

tmp_dir="$(mktemp -d "${TMPDIR:-/tmp}/mytical-session-test.XXXXXX")"
rootfs="$tmp_dir/root"
control_dir="$tmp_dir/control"
dpkg-deb -x "$session_deb" "$rootfs"
dpkg-deb -e "$session_deb" "$control_dir"

wrapper="$rootfs/usr/bin/mytical-session"
desktop="$rootfs/usr/share/wayland-sessions/mytical.desktop"
sddm_conf="$rootfs/etc/sddm.conf.d/10-mytical.conf"
conffiles="$control_dir/conffiles"

# --- Contenido del paquete (dpkg-deb -c) ------------------------------------
listing="$(dpkg-deb -c "$session_deb")"
for path in \
    ./usr/bin/mytical-session \
    ./usr/share/wayland-sessions/mytical.desktop \
    ./etc/sddm.conf.d/10-mytical.conf; do
    grep -qF -- " $path" <<<"$listing" ||
        fail "dpkg-deb -c no lista $path"
done

wrapper_entry="$(printf '%s\n' "$listing" | grep -F ' ./usr/bin/mytical-session' | head -n1 || true)"
case "$wrapper_entry" in
    -rwxr-xr-x*) ;;
    *) fail "el wrapper no está en modo 755 dentro del paquete: ${wrapper_entry:-no encontrado}" ;;
esac

[ -f "$wrapper" ] || fail "falta el wrapper extraído"
[ -x "$wrapper" ] || fail "el wrapper extraído no es ejecutable"
[ "$(stat -c '%a' "$wrapper")" = "755" ] ||
    fail "el wrapper extraído no tiene permisos 755"

# --- Wrapper ----------------------------------------------------------------
[ "$(sed -n '1p' "$wrapper")" = '#!/bin/sh' ] ||
    fail "el wrapper no empieza por #!/bin/sh"

line_nix="$(grep -nF -- 'exec "$HOME/.nix-profile/bin/hyprland-session"' "$wrapper" |
    head -n1 | cut -d: -f1 || true)"
line_hypr="$(grep -nF -- 'exec Hyprland' "$wrapper" | head -n1 | cut -d: -f1 || true)"
line_start="$(grep -nF -- 'exec start-hyprland' "$wrapper" | head -n1 | cut -d: -f1 || true)"

[ -n "$line_nix" ] || fail "el wrapper no ejecuta \$HOME/.nix-profile/bin/hyprland-session"
[ -n "$line_hypr" ] || fail "el wrapper no tiene fallback a Hyprland"
[ -n "$line_start" ] || fail "el wrapper no tiene fallback a start-hyprland"
grep -qF -- '[ -x "$HOME/.nix-profile/bin/hyprland-session" ]' "$wrapper" ||
    fail "el wrapper no comprueba que hyprland-session sea ejecutable"

if [ "$line_nix" -ge "$line_hypr" ] || [ "$line_nix" -ge "$line_start" ]; then
    fail "el wrapper no prefiere \$HOME/.nix-profile/bin/hyprland-session"
fi
[ "$line_hypr" -lt "$line_start" ] ||
    fail "el wrapper debe preferir Hyprland antes que start-hyprland"

# --- .desktop ---------------------------------------------------------------
expect_line "$desktop" '[Desktop Entry]' "mytical.desktop"
expect_line "$desktop" 'Type=Application' "mytical.desktop"
expect_line "$desktop" 'Exec=/usr/bin/mytical-session' "mytical.desktop Exec"
expect_line "$desktop" 'TryExec=/usr/bin/mytical-session' "mytical.desktop TryExec"
expect_line "$desktop" 'DesktopNames=Hyprland' "mytical.desktop DesktopNames"

# --- Conffile de SDDM -------------------------------------------------------
[ -f "$sddm_conf" ] || fail "falta /etc/sddm.conf.d/10-mytical.conf"
expect_line "$conffiles" '/etc/sddm.conf.d/10-mytical.conf' "conffiles"
grep -qxF 'SessionDir=/usr/share/wayland-sessions' "$sddm_conf" ||
    fail "el conffile de SDDM no apunta a /usr/share/wayland-sessions"

# --- Scripts de mantenimiento ----------------------------------------------
postinst="$control_dir/postinst"
postrm="$control_dir/postrm"
[ -f "$postinst" ] || fail "el paquete no incluye DEBIAN/postinst"
[ -x "$postinst" ] || fail "DEBIAN/postinst no es ejecutable"
[ -f "$postrm" ] || fail "el paquete no incluye DEBIAN/postrm"
[ -x "$postrm" ] || fail "DEBIAN/postrm no es ejecutable"

grep -qF -- 'systemctl cat sddm.service' "$postinst" ||
    fail "postinst no comprueba que el servicio sddm exista"
grep -qF -- 'systemctl is-active --quiet sddm' "$postinst" ||
    fail "postinst no comprueba que sddm esté activo"
grep -qF -- 'systemctl restart sddm' "$postinst" ||
    fail "postinst no reinicia sddm"
grep -qF -- '|| true' "$postinst" ||
    fail "postinst no protege el restart con || true"

if grep -Eq '(^|[^[:alnum:]_])(apt-get|apt|dpkg)[[:space:]]' "$postinst"; then
    fail "postinst no debe instalar dependencias"
fi
if grep -Eq '/home/|\$HOME' "$postinst"; then
    fail "postinst no debe tocar directorios de usuario"
fi
if grep -Eq '(^|[^[:alnum:]_])(rm|rmdir|find)[[:space:]]|/home/|\$HOME' "$postrm"; then
    fail "postrm no debe borrar configuración del usuario"
fi

# Idempotencia funcional del postinst con un systemctl simulado. Solo se
# ejecuta si systemd está operativo en la máquina de test.
if [ -d /run/systemd/system ]; then
    fakebin="$tmp_dir/fakebin"
    calls="$tmp_dir/systemctl.calls"
    mkdir -p "$fakebin"
    cat >"$fakebin/systemctl" <<'FAKE'
#!/bin/sh
case "${1:-}" in
    cat)
        [ "${FAKE_EXISTS:-1}" = 1 ] || exit 1
        exit 0
        ;;
    is-active)
        [ "${FAKE_ACTIVE:-1}" = 1 ] || exit 3
        exit 0
        ;;
    restart)
        printf '%s\n' "$*" >> "${FAKE_CALLS:?}"
        exit 0
        ;;
esac
exit 1
FAKE
    chmod 755 "$fakebin/systemctl"

    run_postinst() {
        PATH="$fakebin:$PATH" \
            FAKE_CALLS="$calls" \
            FAKE_ACTIVE="${1:-1}" \
            FAKE_EXISTS="${2:-1}" \
            /bin/sh "$postinst"
    }

    : >"$calls"
    run_postinst 0 1
    [ ! -s "$calls" ] || fail "postinst reinició sddm con el servicio inactivo"

    : >"$calls"
    run_postinst 1 0
    [ ! -s "$calls" ] || fail "postinst reinició sddm sin que el servicio exista"

    : >"$calls"
    run_postinst 1 1
    run_postinst 1 1
    [ "$(wc -l <"$calls")" -eq 2 ] ||
        fail "postinst no es idempotente al ejecutarse dos veces"
    grep -qxF 'restart sddm' "$calls" ||
        fail "postinst no llamó a 'systemctl restart sddm'"
else
    printf 'SKIP: no se prueba postinst en vivo porque systemd no está operativo\n'
fi

# --- Sin sesiones GNOME/Ubuntu ---------------------------------------------
check_no_gnome_ubuntu_session() {
    local deb="$1" current_listing depends field
    current_listing="$(dpkg-deb -c "$deb")"
    if grep -Eq '/(wayland-sessions|xsessions)/[^/]*(gnome|ubuntu)|/(gnome-session|gnome-shell)/' \
        <<<"$current_listing"; then
        fail "$(basename "$deb") incluye una sesión GNOME/Ubuntu"
    fi
    for field in Depends Recommends Suggests Provides; do
        depends="$(dpkg-deb -f "$deb" "$field" 2>/dev/null || true)"
        if grep -Eq '(^|[,[:space:]])(gnome-shell|ubuntu-session|gdm3)([,[:space:]]|$)' \
            <<<"$depends"; then
            fail "$(basename "$deb") declara $field con GNOME/Ubuntu: $depends"
        fi
    done
}

check_no_gnome_ubuntu_session "$session_deb"
check_no_gnome_ubuntu_session "$desktop_deb"

printf 'OK: test_session.sh (%s)\n' "$(basename "$session_deb")"
