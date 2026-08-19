# Dependencias que ninguna distro te instala

Estas son la razón de que "los mismos dotfiles en cualquier máquina" no sea un
problema de symlinks. Cada una hay que instalarla a mano, o desde una fuente
de terceros, en al menos una de las distros objetivo.

**Con Nix casi nada de esto aplica**: cinco de las seis están en nixpkgs y las
gestiona `home.nix`. Ver [`../nix/README.md`](../nix/README.md). Esta página
cubre el camino de los paquetes de la distro.

El estado que se describe abajo se leyó de una instalación real de Ubuntu
24.04 —dónde vive cada binario y si algún paquete lo posee—, así que refleja
lo que de verdad se hizo, no lo que sugieren los manuales.

## Antes que nada: el `PATH` de la sesión

Todas las entradas de abajo instalan un binario en un sitio poco habitual:
`/usr/local/bin`, `~/.local/bin`, `~/.nix-profile/bin`. Eso solo sirve si la
sesión puede verlo, y de serie no puede.

El gestor de acceso arranca el compositor directamente —`hyprland.desktop`
ejecuta `/usr/bin/start-hyprland`— sin pasar por un shell de login. Así que
`~/.profile` no se lee, el `hm-session-vars.sh` de home-manager no se carga, y
Hyprland hereda el `PATH` pelado del sistema:

```
/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin
```

Ni `~/.nix-profile/bin` ni `~/.local/bin` están ahí. Como `exec-once` y todos
los atajos pasan por `/bin/sh -c`, cualquier cosa instalada en esos dos
directorios falla al lanzarse **y no dice nada**: ni error en el log, ni
notificación; el programa simplemente no aparece.

`modules/envs.lua` antepone los dos, calculados desde el `PATH` con el que
arrancó Hyprland. Sin esa línea, `awww`, `quickshell`, `hyprshot` y el script
`volume` están muertos en una máquina con Nix, mientras que `dunst`, `waybar`
y `nm-applet` sí arrancan —no porque estén bien configurados, sino porque
Ubuntu deja una copia de cada uno en `/usr/bin`—. Ese es el patrón a
reconocer: **una sesión a medio arrancar es síntoma de `PATH`**.

El orden también cuenta. `~/.nix-profile/bin` va primero, así que en una
máquina con Nix gana la versión clavada sobre lo que la distro dejara en
`/usr/bin`, que es lo que dan por supuesto las notas de abajo.

## rofi (fork con Wayland)

El `rofi` de Ubuntu es solo X11 y no funciona bajo Hyprland. Aquí hay dos
compilaciones instaladas, y el orden del `PATH` decide por sí solo cuál corre:

| Ruta | Versión | Origen | |
|---|---|---|---|
| `~/.nix-profile/bin/rofi` | 2.0.0 | `nix/home.nix`, envuelto en nixGL | la que corre |
| `/usr/local/bin/rofi` | 1.7.8+wayland1 | el fork de lbonn, compilado a mano | reserva |

El paquete de apt **ya no está instalado** en esta máquina, y `ubuntu.txt`
sigue sin listarlo a propósito: instalarlo solo devolvería un binario de solo
X11 a `/usr/bin`, esperando a un orden de `PATH` que lo alcance.

Desde que `envs.lua` pone `~/.nix-profile/bin` primero, manda la versión de
Nix. Eso es exactamente el reordenamiento del `PATH` que esta sección
advertía, así que se comprobó en la sesión en marcha en vez de darlo por
bueno: la compilación de Nix crea una superficie *layer-shell* (`hyprctl
layers` muestra `namespace: rofi`) y no abre ningún cliente de XWayland. Habla
Wayland de forma nativa.

- Arch: `rofi-wayland` está en los repos oficiales.
- Ubuntu/Debian: compilar desde <https://github.com/lbonn/rofi>.
- Nix: el atributo es `rofi`, que ya va por la **2.0.0**, con Wayland de
  serie. Es un salto grande desde la 1.7.8, pero se comprobó que carga los
  `.rasi` de este repositorio sin errores.

## quickshell

El selector de fondos de `MOD` + `W`.

Aquí ya **solo** lo aporta Nix: la vieja compilación a mano desapareció de
`/usr/local/bin`, así que `quickshell` vive únicamente en
`~/.nix-profile/bin` y el atajo depende del arreglo del `PATH` de arriba. Eso
resuelve de paso el problema de reproducibilidad que había: el checkout suelto
en `~/Downloads/quickshell` ya no pinta nada.

- Arch: `quickshell-git` en el AUR.
- Ubuntu/Debian: compilar desde <https://git.outfoxxed.me/outfoxxed/quickshell>.
- Nix: `quickshell` 0.3.0, envuelto en nixGL.

## awww / awww-daemon

Un fork de `swww`, que pone el fondo de pantalla.

Lo que queda en `/usr/bin/swww-daemon` y `/usr/local/bin/swww` son binarios
copiados a mano que **ningún paquete de dpkg posee**: una actualización de apt
nunca los tocará y una máquina nueva no los tendrá. Con Nix ya son lastre —la
config llama a `awww`, que se resuelve en `~/.nix-profile/bin`— y se pueden
borrar.

- Arch: `swww` está en el AUR; el fork `awww` no está empaquetado.
- Ubuntu/Debian: compilar, o cambiar la config para usar `swww` a secas.
- Nix: `awww` 0.12.1, y aporta **los dos** comandos, `awww` y `awww-daemon`.
  nixpkgs renombró `swww` a `awww`, así que el fork es ya el nombre canónico.

## hyprshot

Un único script de bash; aquí en `~/.local/bin`, que es el otro directorio
que falta del `PATH` de la sesión: el atajo `MOD` + `O` depende del arreglo
descrito arriba.

- Arch: `hyprshot` en el AUR.
- Ubuntu/Debian: copiar el script de <https://github.com/Gustash/Hyprshot>
  al `PATH`.
- Nix: existe, pero se dejó fuera a propósito. Depende de `hyprland`, que
  arrastra Qt 6, y costaba 640 MiB medidos por un script de 60 KB.

## neovim

La configuración de este repositorio es LazyVim, que necesita un Neovim
reciente. Ubuntu 24.04 trae la 0.9.x; aquí está instalada la **0.11.6** en
`~/.local/bin`.

- Arch: `neovim` de los repos está al día.
- Ubuntu/Debian: usar el AppImage o el tarball oficiales, no el paquete.
- Nix: `neovim` 0.12.4.

## brave-browser

Trae su propio repositorio de apt y su propia clave de firma; ver
<https://brave.com/linux/>. En Arch es `brave-bin` en el AUR, y en Nix es
`brave`.

Ojo: el nombre del binario cambia según la distro. El paquete de apt instala
`brave-browser` y el del AUR instala `brave`. `modules/keysbindings.lua`
elige el que exista en vez de dar uno por supuesto.

## pomobar

Proyecto tuyo, al que apunta el módulo `custom/pomobar` de waybar en
`$HOME/Documents/pomobar/`. Nada lo instala, y el módulo no está actualmente
en `modules-right`, así que la barra funciona sin él.

## Fuentes

Las configs piden tres familias:

| Fuente | La usa | ¿Instalada aquí? |
|---|---|---|
| FantasqueSansMono Nerd Font | waybar | sí |
| Iosevka | rofi | **no** |
| CaskaydiaCove Nerd Font | waybar, hyprlock | **no** |

Dos de las tres ya faltan en esta máquina, así que esas configs están cayendo
en silencio a una fuente por defecto. O las instalas desde
<https://github.com/ryanoasis/nerd-fonts> en `~/.local/share/fonts` (y luego
`fc-cache -f`), o cambias las configs a una fuente que sí tengas.
