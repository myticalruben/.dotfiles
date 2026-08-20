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
nix run home-manager/master -- switch --flake .#ruben -b backup
```

`-b backup` renombra a `.backup` cualquier archivo que estorbe, en vez de
borrarlo. Tras la primera activación basta con
`home-manager switch --flake .#ruben`.

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
`dunst`, `waybar`, `nm-applet` y `cliphist` sí salen, pero no desde Nix, sino
desde la copia que Ubuntu deja en `/usr/bin`. Lo que se queda muerto es lo que
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

Esa decisión sigue siendo la de esta configuración por defecto, pero ya no hay
que improvisar para cambiarla: el interruptor `compositorFromNix` de `home.nix`
lo hace, y la configuración `.#vm` del flake lo trae activado.

Cuando se enciende, aparecen tres cosas nuevas en el perfil:

| | |
|---|---|
| `Hyprland` | el paquete de nixpkgs, envuelto en nixGL como los demás |
| `hyprland-session` | el arranque de sesión: prepara el `PATH` y el entorno, y luego lanza el compositor |
| `install-hyprland-session` | registra la entrada en el gestor de acceso; necesita root |

El punto que importa es que **no sustituye a la sesión de Ubuntu, se pone al
lado**. La entrada va a `/usr/local/share/wayland-sessions` con otro nombre
("Hyprland (Nix)"), así que las dos aparecen en la pantalla de acceso y una
sesión de Nix que no levante te cuesta un cierre de sesión, no la máquina.

Son dos pasos, no uno:

```sh
home-manager switch --flake .#ruben   # lo instala
sudo install-hyprland-session         # hace que el gestor lo ofrezca
```

El segundo necesita root y por eso no puede formar parte de la activación.
Solo hay que ejecutarlo una vez: la entrada apunta a `~/.nix-profile/bin`, que
sigue tus generaciones, y no a la ruta del store que fuera la actual ese día.

Antes de encenderlo en la máquina que usas a diario, pruébalo en una VM:
ver [`vm/README.md`](vm/README.md).

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
nix run home-manager/master -- switch --flake .#ruben -b backup
```

Si el usuario de esa máquina no es `ruben`, cambia antes `username` y
`homeDirectory` en `flake.nix`.

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

El closure completo ronda los **4.4 GiB**, y **4.7 GiB** con
`compositorFromNix` encendido: Hyprland cuesta unos 300 MiB en la práctica,
aunque su closure aislado sean 3.0 GiB, porque comparte Mesa y Qt con lo que
ya estaba. `hyprshot` está deliberadamente
fuera: depende de `hyprland`, que arrastra Qt 6 a través de
`hyprland-qtutils`, así que un script de capturas de 60 KB costaba 640 MiB
medidos. Lo aporta el script suelto en `~/.local/bin`, que por eso está en el
`PATH` que añade `envs.lua`.
