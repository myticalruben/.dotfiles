# Dependencias

Enlazar las configuraciones es la mitad fácil. La difícil es que estos
dotfiles dependen de unos 30 programas, y el conjunto de distros que empaqueta
todos ellos está vacío. Este directorio es el mapa honesto de ese hueco.

Si usas el camino de Nix, casi todo esto deja de importarte: ver
[`../nix/README.md`](../nix/README.md).

## Archivos

| Archivo | Qué es |
|---|---|
| `required-commands.txt` | Dependencias como **comandos**, no como nombres de paquete. Es la fuente de verdad: `install.sh --check` lo lee. |
| `ubuntu.txt` | Nombres de apt para Ubuntu 24.04. **Verificados** con `apt-cache` en una máquina real. |
| `ubuntu-ppa.txt` | PPAs de los que depende `ubuntu.txt`. |
| `debian.txt` | Nombres de apt para Debian trixie/sid. **Nombres verificados, instalación sin probar** (ver el propio archivo). |
| `arch.txt` | Nombres de pacman. **Sin verificar.** |
| `arch-aur.txt` | Nombres del AUR. **Sin verificar.** `install.sh` los imprime en vez de instalarlos. |
| `manual.md` | Los que ninguna distro empaqueta. |

"Sin verificar" significa que los nombres se dedujeron, no se comprobaron en
esa distro. Ejecuta `./install.sh --verify-names` en la máquina destino: lista
todos los nombres que el gestor de paquetes local no sabe resolver, no cambia
nada, y convierte la conjetura en una lista concreta.

## Uso

```sh
./install.sh                  # informa qué falta, no toca nada
./install.sh --verify-names   # comprueba que los nombres resuelven aquí
./install.sh --install        # añade repos, instala y enlaza las configs
```

`--install` es el único modo que modifica el sistema, y pregunta antes de
añadir un PPA.

## Disponibilidad

El resumen incómodo: **ninguna distro te lleva hasta el final**. Ubuntu
necesita un PPA y cinco compilaciones a mano; Arch cubre más, pero se apoya en
el AUR.

| Dependencia | Ubuntu 24.04 | Debian trixie | Arch |
|---|---|---|---|
| hyprland, hyprlock | PPA `cppiber` | repos | repos |
| waybar | PPA (0.14; el archivo trae una anterior) | repos | repos |
| wlogout, cliphist, dunst | universe | repos | AUR (wlogout) / repos |
| kitty, thunar, btop, grim, slurp, jq | universe | repos | repos |
| alacritty | PPA `aslatter` | repos | repos |
| rofi **(fork con Wayland)** | compilar | compilar | `rofi-wayland` |
| quickshell | compilar | compilar | AUR |
| awww / swww | compilar | compilar | AUR (`swww`) |
| hyprshot | copiar el script | copiar el script | AUR |
| neovim (suficientemente nuevo) | tarball oficial | repos | repos |
| brave | repo apt propio | repo apt propio | AUR |

Debian **stable** no aparece en la tabla a propósito: Hyprland es demasiado
nuevo para él. Trixie o sid, o nada.

Ver `manual.md` para qué hacer con cada entrada de "compilar".

## Añadir una dependencia

1. Añade el comando a `required-commands.txt`, con qué se rompe sin él.
2. Añade el nombre de paquete a cada archivo de distro que lo tenga.
3. Si ninguna distro lo empaqueta, documéntalo en `manual.md`.
