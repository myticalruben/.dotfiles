#!/usr/bin/env bash
#
# Deja una VM de Ubuntu recien instalada corriendo Hyprland desde Nix.
#
# Se ejecuta DENTRO de la VM, no en tu equipo. La comprobacion de abajo esta
# para eso: activar la configuracion `vm` en la maquina real convertiria
# ~/.config en rutas de solo lectura del store y te quitaria el flujo de
# edicion en caliente. Molesto de deshacer, facil de evitar.

set -euo pipefail

REPO_URL="https://github.com/myticalruben/.dotfiles.git"
BRANCH="feat/hyprland-from-nix"
CHECKOUT="$HOME/.dotfiles"
CONFIG="vm"
FORCE=0

for arg in "$@"; do
  case "$arg" in
    --force) FORCE=1 ;;
    --branch=*) BRANCH="${arg#*=}" ;;
    -h|--help)
      sed -n '2,12p' "$0" | sed 's/^# \{0,1\}//'
      echo
      echo "Uso: bootstrap.sh [--force] [--branch=NOMBRE]"
      exit 0
      ;;
    *) echo "opcion desconocida: $arg" >&2; exit 2 ;;
  esac
done

say()  { printf '\n\033[1m==> %s\033[0m\n' "$*"; }
warn() { printf '\033[33m    aviso: %s\033[0m\n' "$*"; }
die()  { printf '\033[31m    error: %s\033[0m\n' "$*" >&2; exit 1; }

# --------------------------------------------------------------- guardas ---

say "Comprobando que esto es una VM"
# systemd-detect-virt imprime "none" Y sale con codigo 1 cuando no hay
# virtualizacion, asi que un "|| echo none" duplicaria el valor y la
# comparacion de abajo no casaria nunca. Basta con tragarse el codigo.
virt="$(systemd-detect-virt 2>/dev/null || true)"
virt="${virt:-none}"
if [ "$virt" = "none" ]; then
  if [ "$FORCE" -eq 1 ]; then
    warn "no se detecta virtualizacion, pero --force lo permite"
  else
    die "esto no parece una VM (systemd-detect-virt: none).
    Si de verdad quieres activar la configuracion 'vm' aqui, repite con --force.
    Ten en cuenta que dejara ~/.config apuntando a rutas de solo lectura."
  fi
else
  echo "    virtualizacion detectada: $virt"
fi

# La configuracion 'vm' del flake fija el usuario. Si no coincide, home-manager
# fallaria a mitad de activacion con un mensaje mucho menos claro que este.
FLAKE_USER="ruben"
if [ "$(id -un)" != "$FLAKE_USER" ]; then
  die "esta configuracion espera el usuario '$FLAKE_USER', y tu eres '$(id -un)'.
    Cambia 'vmUsername' en flake.nix, o crea un usuario '$FLAKE_USER' en la VM."
fi

command -v sudo >/dev/null || die "hace falta sudo"

# ------------------------------------------------------------------- nix ---

if ! command -v nix >/dev/null 2>&1; then
  say "Instalando Nix (instalador de Determinate, con flakes de serie)"
  curl -fsSL https://install.determinate.systems/nix | sh -s -- install --no-confirm
  # El instalador deja el perfil listo, pero este shell ya esta arrancado.
  . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
else
  echo "    nix ya instalado: $(nix --version)"
fi

# ------------------------------------------------------------- el repo ----

if [ ! -d "$CHECKOUT/.git" ]; then
  say "Clonando el repositorio en $CHECKOUT"
  command -v git >/dev/null || sudo apt-get install -y git
  git clone --branch "$BRANCH" "$REPO_URL" "$CHECKOUT"
else
  say "Actualizando $CHECKOUT a $BRANCH"
  git -C "$CHECKOUT" fetch origin "$BRANCH"
  git -C "$CHECKOUT" checkout "$BRANCH"
  git -C "$CHECKOUT" pull --ff-only origin "$BRANCH"
fi

# --------------------------------------------------- permisos de la sesion --

# Hyprland habla directamente con DRM y con los dispositivos de entrada. En
# Ubuntu eso se concede por grupo, y sin esto arranca y muere sin abrir nada.
say "Comprobando grupos (video, input, render)"
for grp in video input render; do
  if getent group "$grp" >/dev/null && ! id -nG | tr ' ' '\n' | grep -qx "$grp"; then
    echo "    anadiendo $(id -un) a $grp"
    sudo usermod -aG "$grp" "$(id -un)"
    NEED_RELOGIN=1
  fi
done

# ------------------------------------------------- entorno de la maquina ---

# VirtualBox no da una GPU con la que Hyprland pueda renderizar por hardware de
# forma fiable. Forzar Mesa por software es lento pero arranca, que es de lo
# que trata esta prueba.
if [ "$virt" = "oracle" ]; then
  say "VirtualBox detectado: escribiendo ~/.config/hyprland-session.env"
  mkdir -p "$HOME/.config"
  cat > "$HOME/.config/hyprland-session.env" <<'ENV'
# Escrito por nix/vm/bootstrap.sh para una VM de VirtualBox.
#
# El controlador VMSVGA no ofrece una ruta de render por hardware que Hyprland
# pueda usar, asi que se le pide a Mesa que rasterice por software. Va lento,
# pero arranca; y lo que se prueba aqui es que la configuracion levanta, no el
# rendimiento.
export LIBGL_ALWAYS_SOFTWARE=1
export WLR_RENDERER_ALLOW_SOFTWARE=1

# El cursor por hardware es lo primero que falla en una GPU virtual: la sesion
# arranca pero te quedas sin puntero visible.
export WLR_NO_HARDWARE_CURSORS=1
ENV
fi

# -------------------------------------------------------------- activar ---

say "Activando home-manager (.#$CONFIG)"
cd "$CHECKOUT"
nix run home-manager/master -- switch --flake ".#$CONFIG" -b backup

say "Instalando la entrada de sesion (necesita root)"
sudo "$HOME/.nix-profile/bin/install-hyprland-session"

# ----------------------------------------------------------- resultado ---

say "Listo"
cat <<FIN

    Comprueba antes de reiniciar:

      command -v Hyprland hyprland-session awww quickshell
      ls /usr/local/share/wayland-sessions/

    Luego cierra sesion y, en la pantalla de acceso, elige "Hyprland (Nix)"
    en el selector de sesion (suele ser un engranaje o una esquina).

FIN

if [ "${NEED_RELOGIN:-0}" = "1" ]; then
  warn "se te anadio a grupos nuevos: hace falta reiniciar la VM para que apliquen"
fi
