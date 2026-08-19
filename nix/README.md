# Nix + home-manager

Alternativa a `setup.py` que gestiona los mismos archivos de `~/.config`, pero
con versiones clavadas: `flake.lock` registra revisiones exactas de nixpkgs y
home-manager, así que otra máquina recibe *las mismas* herramientas, no "lo
que traiga la distro hoy".

**Elige uno de los dos caminos.** No ejecutes `setup.py` y home-manager a la
vez: ambos quieren ser dueños de `~/.config/hypr`, y home-manager se niega a
pisar un symlink que no creó él. Si vienes de `setup.py`, borra antes sus
enlaces: son solo symlinks, borrarlos no toca nada del repositorio.

## Puesta en marcha

Este repositorio no instala Nix: necesita root, crea `/nix` y añade un daemon.
Instálalo tú primero. El instalador de Determinate es el habitual y, a
diferencia del oficial, deja los flakes activados de serie:

```sh
curl -fsSL https://install.determinate.systems/nix | sh -s -- install
```

Si usaste el instalador oficial, activa los flakes a mano o tendrás que pasar
la bandera en cada comando:

```sh
mkdir -p ~/.config/nix
echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf
```

Después, desde el repositorio:

```sh
nix run home-manager/master -- switch --flake .#ruben-alexander -b backup
```

`-b backup` renombra a `.backup` cualquier archivo que estorbe, en vez de
borrarlo. Tras la primera activación basta con
`home-manager switch --flake .#ruben-alexander`.

## Cierra la sesión después de activar

Una sesión de Hyprland ya en marcha heredó su `PATH` del momento en que
entraste. Si instalaste Nix después, ese `PATH` no incluye
`~/.nix-profile/bin`, y tus atajos seguirán abriendo los binarios de la
distro aunque la activación haya ido bien.

Cierra sesión y vuelve a entrar. Para comprobarlo:

```sh
tr '\0' '\n' < /proc/$(pgrep -x Hyprland)/environ | grep ^PATH= | tr ':' '\n' | grep nix-profile
```

Si no imprime nada, la sesión todavía no ve los paquetes de Nix.

## En otra máquina

Cambia `username` y `homeDirectory` en `flake.nix`, o añade una segunda
entrada en `homeConfigurations` y selecciónala por nombre. `home.nix` da por
supuesto que el repositorio está en `~/.dotfiles`.

## Las configs se siguen editando en su sitio

`home.nix` enlaza con `mkOutOfStoreSymlink`, no copiando al store. Así
`~/.config/hypr/hyprland.lua` sigue apuntando al repositorio y editarlo sigue
editando el checkout: el mismo flujo que daba `setup.py`.

El comportamiento normal de home-manager sería copiar los archivos a
`/nix/store` en solo lectura, y entonces cada retoque exigiría un `switch`.
Más riguroso y mucho más incómodo para una configuración que tocas a diario.

Efecto secundario: `~/.config` sigue **la rama de git que tengas activa**.

## Cómo se reparten los paquetes

Todo lo que invocan las configs viene de Nix, en dos grupos.

**Sin GPU de por medio**, instalados tal cual: `cliphist`, `wl-clipboard`,
`grim`, `slurp`, `playerctl`, `brightnessctl`, `pulseaudio` (pactl),
`wireplumber` (wpctl), `jq`, `imagemagick`, `btop`, `neovim`, `awww`.

**Abren ventanas**, envueltos con [nixGL](https://github.com/nix-community/nixGL):
`waybar`, `rofi`, `kitty`, `alacritty`, `dunst`, `wlogout`, `quickshell`,
`pavucontrol`, `networkmanagerapplet`, `brave`.

El envoltorio importa porque esto no es NixOS. Esos programas se compilaron
contra la Mesa de nixpkgs, mientras que el núcleo y los drivers vienen de
Ubuntu; sin nixGL se caen al arrancar con un error de GL o EGL. `wrapGL`, en
`home.nix`, sustituye cada binario por un shim que lo lanza a través de
`nixGLIntel`, y deja pasar intacto todo lo demás: archivos `.desktop`, iconos
y datos compartidos.

Ambas máquinas usan gráficos integrados, que es el caso que Mesa y nixGL
resuelven limpio. Con NVIDIA esto se complica bastante: haría falta
`nixGLNvidia` y una versión de driver que coincida exactamente con la del
sistema.

### Comprobado

Medido en esta máquina, no supuesto:

| | Sin envolver | Envuelto en nixGL |
|---|---|---|
| alacritty | `exit=1`, `NotSupported("provided display handle is not supported")` | `exit=0` |
| kitty | `exit=1` | `exit=0` |

La prueba en una máquina nueva es esa misma: lanzar `alacritty -e true` por
las dos vías y comparar los códigos de salida.

## Por qué el compositor no está en esa lista

Hyprland se sigue instalando desde la distro, y es a propósito. No es que
falte en nixpkgs —está, la misma versión 0.56.2—; el motivo es el modo de
fallo. Un terminal que no arranca es una molestia que arreglas desde otro
terminal. Un compositor que no arranca te deja sin sesión desde la que
arreglarlo.

Además tiene que encontrarlo el gestor de sesión, que lee los archivos de
`/usr/share/wayland-sessions`. Eso queda fuera del alcance de home-manager y
fuera del `~/.config` que cubre este repositorio.

Si aun así lo quieres desde Nix: añade `hyprland` a la lista envuelta, escribe
un archivo de sesión que apunte al binario envuelto y **mantén instalado el
paquete de la distro**, para tener siempre una sesión que arranque.

## Solución de problemas

### `install.sh` dice que faltan quickshell, awww o awww-daemon

No faltan: los trae home-manager. `install.sh` solo mira los paquetes de la
distro, no sabe nada de Nix, así que los da por ausentes hasta que activas
home-manager en esa máquina.

Los tres salen de dos paquetes de este `home.nix`:

| Comando | Paquete de Nix |
|---|---|
| `quickshell`, `qs` | `quickshell`, envuelto en nixGL |
| `awww`, `awww-daemon` | `awww` (nixpkgs renombró `swww` a `awww`) |

La solución es activar home-manager ahí:

```sh
cd ~/.dotfiles
nix run home-manager/master -- switch --flake .#ruben-alexander -b backup
```

Si el usuario de esa máquina no es `ruben-alexander`, cambia antes `username`
y `homeDirectory` en `flake.nix`.

Después, cierra sesión y vuelve a entrar (ver arriba), y compruébalo con:

```sh
command -v quickshell awww awww-daemon
```

Las tres rutas deben empezar por `~/.nix-profile/bin`.

## stateVersion

`home.stateVersion = "24.11"` en `home.nix` **no** significa "la versión que
quiero". Es la release contra cuyos valores por defecto se escribió esta
configuración, y cambiarla después puede alterar comportamientos en silencio.
Déjala como está.

## Tamaño

El closure completo ronda los **4.4 GiB**. `hyprshot` está deliberadamente
fuera: depende de `hyprland`, que arrastra Qt 6 a través de
`hyprland-qtutils`, así que un script de capturas de 60 KB costaba 640 MiB
medidos. Lo aporta el paquete de la distro.
