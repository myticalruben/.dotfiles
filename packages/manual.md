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

## rofi (fork con Wayland)

El `rofi` de Ubuntu es solo X11 y no funciona bajo Hyprland. Lo que corre aquí
es `rofi 1.7.8+wayland1` en `/usr/local/bin`, compilado a mano; ningún paquete
de apt lo posee.

**Están instalados los dos**, y el que funciona gana solo porque
`/usr/local/bin` va antes que `/usr/bin` en el `PATH`:

| Ruta | Versión | Origen |
|---|---|---|
| `/usr/local/bin/rofi` | 1.7.8+wayland1 | compilado a mano, funciona |
| `/usr/bin/rofi` | 1.7.5 | paquete apt `rofi`, solo X11 |

Si algo reordena el `PATH`, el lanzador pasa a ser la versión X11 sin avisar y
deja de funcionar bajo Hyprland. Desinstalar el paquete de apt
(`sudo apt remove rofi`) lo hace imposible. `ubuntu.txt` **no** lista `rofi`
justamente por esto: instalarlo solo recrearía el solapamiento.

- Arch: `rofi-wayland` está en los repos oficiales.
- Ubuntu/Debian: compilar desde <https://github.com/lbonn/rofi>.
- Nix: el atributo es `rofi`, que ya va por la **2.0.0**, con Wayland de
  serie. Es un salto grande desde la 1.7.8, pero se comprobó que carga los
  `.rasi` de este repositorio sin errores.

## quickshell

El selector de fondos de `MOD` + `W`. Aquí está compilado en `/usr/local/bin`
(el checkout vive en `~/Downloads/quickshell`, lo cual es en sí mismo un
problema de reproducibilidad: debería estar en un sitio deliberado).

- Arch: `quickshell-git` en el AUR.
- Ubuntu/Debian: compilar desde <https://git.outfoxxed.me/outfoxxed/quickshell>.
- Nix: `quickshell` 0.3.0, envuelto en nixGL.

## awww / awww-daemon

Un fork de `swww`, que pone el fondo de pantalla. Los binarios están en
`/usr/bin` pero **ningún paquete de dpkg los posee**: se copiaron a mano, así
que una actualización de apt nunca los tocará y una máquina nueva no los
tendrá.

- Arch: `swww` está en el AUR; el fork `awww` no está empaquetado.
- Ubuntu/Debian: compilar, o cambiar la config para usar `swww` a secas.
- Nix: `awww` 0.12.1, y aporta **los dos** comandos, `awww` y `awww-daemon`.
  nixpkgs renombró `swww` a `awww`, así que el fork es ya el nombre canónico.

## hyprshot

Un único script de bash; aquí en `/usr/local/bin`.

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
