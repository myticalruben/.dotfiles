# Nix + home-manager

Alternativa a `setup.py` que gestiona los mismos archivos de `~/.config`, pero
con versiones clavadas: `flake.lock` registra revisiones exactas de nixpkgs y
home-manager, así que otra máquina recibe *las mismas* herramientas, no "lo
que traiga la distro hoy".

**Elige uno de los dos caminos.** No ejecutes `setup.py` y home-manager a la
vez: ambos quieren ser dueños de `~/.config/hypr`, y home-manager se niega a
pisar un symlink que no creó él. Si vienes de `setup.py`, quita antes sus
enlaces:

```sh
python3 setup.py --unlink --dry-run   # mira qué se va a quitar
python3 setup.py --unlink
```

Solo borra symlinks que apunten a este checkout, así que no toca nada del
repositorio ni nada que hayas puesto tú.

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
nix run .#home-manager -- switch --flake .#default --impure -b backup
```

`-b backup` renombra a `.backup` cualquier archivo que estorbe, en vez de
borrarlo. Tras la primera activación basta con
`home-manager switch --flake .#default --impure`.

`--impure` solo deja leer `$USER` y `$HOME`: son los dos únicos datos que
cambian entre una VM, un portátil y un PC. Las versiones de todos los paquetes
siguen saliendo de `flake.lock`.

## El `PATH` de la sesión

Nix instala todo en `~/.nix-profile/bin`, y **la sesión no tiene ese
directorio en el `PATH`**. Conviene decirlo claro porque la respuesta
intuitiva es la equivocada: esto **no** se arregla cerrando sesión. No es que
el `PATH` se haya quedado viejo, es que nadie lo pone ahí nunca.

El gestor de acceso ejecuta `/usr/bin/start-hyprland` directamente, sin ningún
shell de login por medio. Así que `~/.profile` no se lee, el
`hm-session-vars.sh` que escribe home-manager no se carga, y Hyprland arranca
con el `PATH` pelado del sistema. Como `exec-once` y los atajos pasan por
`/bin/sh -c`, todo lo que solo vive en Nix falla al arrancar **sin decir
nada**: ni error en el log, ni notificación.

El síntoma es una sesión a medio arrancar, que es justo lo que despista.
`dunst`, `nm-applet` y `cliphist` sí salen, pero no desde Nix, sino
desde la copia que Ubuntu deja en `/usr/bin`; `waybar` se lanza a mano con
SUPER+Shift+W (su autostart está comentado a propósito). Lo que se queda
muerto es lo que
solo aporta Nix —`awww` y `awww-daemon`, o sea ningún fondo de pantalla, y
`quickshell` (SUPER+W)— más lo que vive en `~/.local/bin`: `hyprshot`
(SUPER+O) y el script `volume`.

`hypr/modules/envs.lua` lo arregla en la única capa que siempre se ejecuta, la
config del propio compositor:

```lua
local extra = home .. "/.nix-profile/bin:" .. home .. "/.local/bin"
if not path:find(extra, 1, true) then
    hl.env("PATH", extra .. ":" .. path)
end
```

Tres detalles que conviene no perder:

- **Se calcula, no se escribe a mano.** El valor se construye a partir del
  `PATH` con el que arrancó Hyprland, así que la misma línea no hace nada en
  una máquina de `setup.py`, donde esos dos directorios no existen.
- **Nix va primero**, para que gane la versión clavada sobre lo que la distro
  dejara en `/usr/bin`, que es el propósito entero de este directorio.
- **El guard no es adorno.** `env` fija la variable en el compositor y
  sobrevive a `hyprctl reload`, que vuelve a leer la config. Sin el `find`,
  cada reload apilaba otra copia del prefijo.

`hl.env` llega a los procesos que lanza Hyprland, así que cubre por igual los
`exec-once` y los atajos. Lo que **no** basta es un `home-manager switch`: la
variable se fija cuando el compositor lee su config, de modo que hace falta un
`hyprctl reload` o una sesión nueva.

Para comprobarlo hay que mirar un proceso *hijo*, no el compositor:

```sh
tr '\0' '\n' < /proc/$(pgrep -x dunst)/environ | grep ^PATH= | tr ':' '\n' | grep nix-profile
```

Sobre `/proc/$(pgrep -x Hyprland)/environ` no sirve, y esa es una trampa fácil
de pisar: ese archivo es una foto del entorno con el que se ejecutó el
proceso, y no refleja los `setenv` posteriores. Saldría vacío aunque todo esté
bien.

## En otra máquina

No hay que tocar el flake. La cuenta y el home salen de `$USER` y `$HOME` al
activar con `--impure`; el repositorio tiene que estar en `~/.dotfiles`
(`bootstrap.sh` lo clona ahí).

## Las configs se siguen editando en su sitio

`home.nix` enlaza con `mkOutOfStoreSymlink`, no copiando al store. Así
`~/.config/hypr/hyprland.lua` sigue apuntando al repositorio y editarlo sigue
editando el checkout: el mismo flujo que daba `setup.py`.

El comportamiento normal de home-manager sería copiar los archivos a
`/nix/store` en solo lectura, y entonces cada retoque exigiría un `switch`.
Más riguroso y mucho más incómodo para una configuración que tocas a diario.

Efecto secundario: `~/.config` sigue **la rama de git que tengas activa**.

## Cómo se reparten los paquetes

Todo lo que invocan las configs sale de Nix, en un solo conjunto. No hay
variantes por máquina: la misma lista se instala en VM, portátil y PC.

**Sin GPU de por medio**, instalados tal cual: `cliphist`, `wl-clipboard`,
`grim`, `slurp`, `playerctl`, `brightnessctl`, `pulseaudio` (pactl),
`wireplumber` (wpctl), `jq`, `imagemagick`, `btop`, `awww`.

Neovim no está en esa lista porque no lo instala este flake: vive en su propio
repositorio, con su propio comando (`nix run github:myticalruben/nvim`). Ver
[su README](https://github.com/myticalruben/nvim).

**Abren ventanas**, envueltos con [nixGL](https://github.com/nix-community/nixGL):
`waybar`, `rofi`, `kitty`, `alacritty`, `dunst`, `wlogout`, `quickshell`,
`pavucontrol`, `networkmanagerapplet`, `brave`, `thunar` y `hyprlock`.

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

## Por qué el compositor sí está

Hyprland viene de Nix en la única configuración. No sustituye a la sesión de
la distro: la entrada de Nix se registra al lado, con otro nombre, y las dos
aparecen en el gestor de acceso. Una sesión de Nix que no levante cuesta un
cierre de sesión, no el equipo; la de la distro sigue ahí.

El riesgo real no es empaquetar Hyprland —está en nixpkgs, la misma 0.56.2—
sino el modo de fallo de un compositor. Por eso se instala al lado y no en
lugar de.

En el perfil aparecen tres cosas:

| | |
|---|---|
| `Hyprland` | el paquete de nixpkgs, envuelto en nixGL como los demás |
| `hyprland-session` | el arranque de sesión: prepara el `PATH` y el entorno, y luego lanza el compositor |
| `install-hyprland-session` | registra la entrada en el gestor de acceso; necesita root |

Son dos pasos, no uno:

```sh
nix run .#home-manager -- switch --flake .#default --impure   # lo instala
sudo install-hyprland-session                                # lo registra
```

El segundo necesita root y por eso no puede formar parte de la activación.
Solo hay que ejecutarlo una vez: la entrada apunta a `~/.nix-profile/bin`, que
sigue tus generaciones, y no a la ruta del store que fuera la actual ese día.

La entrada se registra donde el gestor de acceso de esa máquina la vaya a
leer, que no es el mismo sitio en todas: GDM hereda `XDG_DATA_DIRS` y encuentra
`/usr/local/share`, mientras que SDDM y LightDM leen listas explícitas de su
propia configuración. `install-hyprland-session` lo detecta en vez de suponerlo;
`--dry-run` te lo cuenta sin tocar nada ni pedir root.

Todo el procedimiento, para VM o para hardware real, está en
[`setup/README.md`](setup/README.md).

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
nix run .#home-manager -- switch --flake .#default --impure -b backup
```

Después, `hyprctl reload` o una sesión nueva (ver **El `PATH` de la
sesión**), y compruébalo con:

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

Medido con `nix path-info -Sh` sobre la generación de home-manager:
**3.8 GiB**, la misma en VM, portátil y PC. No hay una variante "ligera" y
otra "completa"; hay una sola.

De dónde sale el ahorro: `nixGL` se construye aquí con `enable32bits = false`
y sin las extensiones Intel, así que no arrastra una segunda Mesa ni su LLVM
(~1.3 GiB menos). `brave` (448 MiB) forma parte de esa cifra. `hyprshot` sigue
deliberadamente fuera: depende de `hyprland`, que arrastra Qt 6 a través de
`hyprland-qtutils`, así que un script de capturas de 60 KB costaba 640 MiB
medidos. Lo aporta el script suelto en `~/.local/bin`, que por eso está en el
`PATH` que añade `envs.lua`.

Medido en las VM de prueba: `.#default` da 3.8 GiB en Arch y en Ubuntu 26.04.
La activación fue de segundos con la caché caliente; en Ubuntu la primera vez
tardó 64 s porque instaló el closure completo.

## Sesión gráfica

Probada en las dos VM. En Arch, con el backend DRM de QEMU, Hyprland 0.56.2
arrancó en `Virtual-1` (1280x800) con waybar, quickshell, kitty, dunst,
nm-applet, cliphist y awww; el fondo se restauró desde `Wallpapers/01.png` y
`grim` capturó la pantalla.

En Ubuntu, tras añadirle una GPU virtio, también arrancó en `Virtual-1`
(1280x800) con quickshell, kitty, dunst y awww; `grim` capturó el selector de
fondos con las miniaturas. Mesa cayó a `kms_swrast` (software) porque el
display no expone virgl; para render por hardware, usa Display=VirGL.

La diferencia importante: con QEMU stdvga/bochs (PCI `1234:1111`) no hay
`/dev/dri/renderD128` ni driver Mesa, y Aquamarine no encuentra EGLDevice. No
es la configuración; es la GPU emulada.
