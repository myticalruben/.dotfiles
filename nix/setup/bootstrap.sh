#!/usr/bin/env bash
#
# Deja una maquina corriendo Hyprland desde Nix: instala Nix si falta, clona
# el repositorio, activa home-manager y registra la entrada de sesion.
#
# Sirve igual para una VM de prueba y para un equipo real. La diferencia esta
# en que configuracion se activa:
#
#   pc  (por defecto)  configs enlazadas al checkout, editables en caliente
#   vm                 configs copiadas al store, de solo lectura
#
# La variante `vm` existe para demostrar que la sesion arranca desde el flake
# y nada mas. En un equipo que usas a diario eso solo estorba, porque te quita
# poder tocar y recargar.

set -euo pipefail

REPO_URL="https://github.com/myticalruben/.dotfiles.git"
BRANCH="feat/hyprland-from-nix"
CHECKOUT="$HOME/.dotfiles"
CONFIG="pc"
FORCE=0

for arg in "$@"; do
  case "$arg" in
    --force)    FORCE=1 ;;
    --config=*) CONFIG="${arg#*=}" ;;
    --branch=*) BRANCH="${arg#*=}" ;;
    -h|--help)
      sed -n '2,16p' "$0" | sed 's/^# \{0,1\}//'
      echo
      echo "Uso: bootstrap.sh [--config=pc|vm] [--branch=NOMBRE] [--force]"
      exit 0
      ;;
    *) echo "opcion desconocida: $arg" >&2; exit 2 ;;
  esac
done

say()  { printf '\n\033[1m==> %s\033[0m\n' "$*"; }
warn() { printf '\033[33m    aviso: %s\033[0m\n' "$*"; }
die()  { printf '\033[31m    error: %s\033[0m\n' "$*" >&2; exit 1; }

# --------------------------------------------------------------- guardas ---

# systemd-detect-virt imprime "none" Y sale con codigo 1 cuando no hay
# virtualizacion, asi que un "|| echo none" duplicaria el valor y la
# comparacion no casaria nunca. Basta con tragarse el codigo.
virt="$(systemd-detect-virt 2>/dev/null || true)"
virt="${virt:-none}"

say "Comprobando el destino"
echo "    configuracion   : .#$CONFIG"
echo "    virtualizacion  : $virt"

# La unica combinacion que hace dano es la de solo lectura en una maquina de
# verdad: te deja ~/.config apuntando al store y sin forma de editar nada.
if [ "$CONFIG" = "vm" ] && [ "$virt" = "none" ]; then
  if [ "$FORCE" -eq 1 ]; then
    warn "activando la variante inmutable en hardware real, porque lo pediste"
  else
    die "'--config=vm' deja ~/.config en rutas de solo lectura, y esto no
    parece una VM. Para un equipo real usa la de por defecto:

        bash bootstrap.sh

    Si de verdad quieres la inmutable aqui, repite con --force."
  fi
fi

command -v sudo >/dev/null || die "hace falta sudo"

# --------------------------------------------------------------- la GPU ---

# home.nix fija nixGLIntel, que es Mesa. Con grafica integrada de Intel o AMD
# va bien en cualquier distro. Con NVIDIA no: hace falta nixGLNvidia y que
# coincida EXACTAMENTE con la version del driver del host.
say "Mirando la GPU"
gpu="$(lspci 2>/dev/null | grep -iE 'vga|3d controller' || true)"
# shellcheck disable=SC2001  # lspci devuelve varias lineas y hay que indentarlas todas
echo "${gpu:-    (lspci no disponible)}" | sed 's/^/    /'
if printf '%s' "$gpu" | grep -qi nvidia; then
  warn "detectada una NVIDIA. home.nix usa nixGLIntel (Mesa), que no la usara."
  warn "si la sesion no arranca, hay que cambiar a nixGLNvidia en nix/home.nix"
  warn "con la version exacta del driver instalado."
fi

# ------------------------------------------------------------------- nix ---

if ! command -v nix >/dev/null 2>&1; then
  say "Instalando Nix (instalador de Determinate, con flakes de serie)"
  curl -fsSL https://install.determinate.systems/nix | sh -s -- install --no-confirm
  # shellcheck source=/dev/null  # lo crea el instalador que acaba de correr
  . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
else
  echo "    nix ya instalado: $(nix --version)"
fi

# ------------------------------------------------------------- el repo ----

install_git() {
  if   command -v apt-get >/dev/null; then sudo apt-get install -y git
  elif command -v pacman  >/dev/null; then sudo pacman -S --noconfirm git
  elif command -v dnf     >/dev/null; then sudo dnf install -y git
  elif command -v zypper  >/dev/null; then sudo zypper install -y git
  else die "no se reconoce el gestor de paquetes: instala git a mano"
  fi
}

if [ ! -d "$CHECKOUT/.git" ]; then
  say "Clonando el repositorio en $CHECKOUT"
  command -v git >/dev/null || install_git
  git clone --branch "$BRANCH" "$REPO_URL" "$CHECKOUT"
else
  say "Actualizando $CHECKOUT a $BRANCH"
  git -C "$CHECKOUT" fetch origin "$BRANCH"
  git -C "$CHECKOUT" checkout "$BRANCH"
  git -C "$CHECKOUT" pull --ff-only origin "$BRANCH"
fi

# ------------------------------------------------------------- el usuario ---

# Se lee del flake en vez de repetirlo aqui: el valor ya vive en flake.nix y
# tener una tercera copia solo garantiza que algun dia digan cosas distintas.
# Por eso esta comprobacion va detras del clonado y no antes.
FLAKE_USER="$(sed -n 's/^[[:space:]]*vmUsername = "\(.*\)";$/\1/p' "$CHECKOUT/flake.nix" | head -n1)"

if [ -z "$FLAKE_USER" ]; then
  warn "no se pudo leer vmUsername de flake.nix; se omite la comprobacion"
elif [ "$(id -un)" != "$FLAKE_USER" ]; then
  die "las configuraciones .#pc y .#vm esperan el usuario '$FLAKE_USER', y tu
    eres '$(id -un)'. home-manager fallaria a mitad de la activacion, asi que
    se para aqui. Cambia 'vmUsername' en $CHECKOUT/flake.nix y repite."
fi

# --------------------------------------------------- permisos de la sesion --

# Hyprland habla directamente con DRM y con los dispositivos de entrada. En la
# mayoria de distros eso se concede por grupo, y sin esto arranca y muere sin
# llegar a abrir nada.
say "Comprobando grupos (video, input, render)"
NEED_RELOGIN=0
for grp in video input render; do
  if getent group "$grp" >/dev/null && ! id -nG | tr ' ' '\n' | grep -qx "$grp"; then
    echo "    anadiendo $(id -un) a $grp"
    sudo usermod -aG "$grp" "$(id -un)"
    NEED_RELOGIN=1
  fi
done

# ------------------------------------------------- entorno de la maquina ---

ENVFILE="$HOME/.config/hyprland-session.env"
if [ "$virt" = "oracle" ]; then
  say "VirtualBox detectado: escribiendo $ENVFILE"
  mkdir -p "$HOME/.config"
  cat > "$ENVFILE" <<'ENV'
# Escrito por nix/setup/bootstrap.sh para una VM de VirtualBox.
#
# El controlador VMSVGA no ofrece una ruta de render por hardware que Hyprland
# pueda usar, asi que se le pide a Mesa que rasterice por software. Va lento,
# pero arranca; y lo que se prueba en una VM es que la configuracion levanta,
# no cuanto rinde.
export LIBGL_ALWAYS_SOFTWARE=1
export WLR_RENDERER_ALLOW_SOFTWARE=1

# El cursor por hardware es lo primero que falla en una GPU virtual: la sesion
# arranca pero te quedas sin puntero visible.
export WLR_NO_HARDWARE_CURSORS=1
ENV
elif [ -f "$ENVFILE" ] && grep -q LIBGL_ALWAYS_SOFTWARE "$ENVFILE"; then
  # Heredado de una prueba en VM. En hardware real solo sirve para ir lento.
  warn "$ENVFILE fuerza el render por software y esto no es una VM."
  warn "renombrado a $ENVFILE.vm-backup"
  mv "$ENVFILE" "$ENVFILE.vm-backup"
fi

# -------------------------------------------------------------- activar ---

say "Activando home-manager (.#$CONFIG)"
cd "$CHECKOUT"
nix run home-manager/master -- switch --flake ".#$CONFIG" -b backup

say "Registrando la entrada de sesion"
"$HOME/.nix-profile/bin/install-hyprland-session" --dry-run
sudo "$HOME/.nix-profile/bin/install-hyprland-session"

# ----------------------------------------------------------- resultado ---

say "Listo"
cat <<'FIN'

    Comprueba antes de reiniciar:

      command -v Hyprland hyprland-session awww quickshell

    Cierra sesion y elige "Hyprland (Nix)" en el selector del gestor de
    acceso. La sesion de la distro sigue ahi, intacta, por si acaso.

    Si no arranca, lanzalo desde una TTY (Ctrl+Alt+F3) para ver el error:

      hyprland-session

FIN

if [ "$NEED_RELOGIN" = "1" ]; then
  warn "se te anadio a grupos nuevos: reinicia para que apliquen"
fi
