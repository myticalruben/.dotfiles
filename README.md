# dotfiles

Configuración de escritorio Hyprland: Hyprland (config en Lua), waybar, rofi,
dunst, wlogout, quickshell, btop y neovim.

## Instalación

Hay dos caminos. **Son alternativas, no capas**: los dos quieren ser dueños de
`~/.config`, así que elige uno.

### Con Nix (versiones clavadas)

Instala las dependencias con las versiones exactas que registra `flake.lock`,
de modo que otra máquina recibe *lo mismo*, no lo que traiga la distro esa
semana. Ver [`nix/`](nix/README.md).

```sh
git clone git@github.com:myticalruben/.dotfiles.git ~/.dotfiles
cd ~/.dotfiles
nix run home-manager/master -- switch --flake .#ruben -b backup
```

Con `.#ruben` Hyprland sigue viniendo de la distro, a propósito: un
compositor que no arranca te deja sin sesión desde la que arreglarlo. El
porqué está en [`nix/README.md`](nix/README.md).

Para que **también** el compositor salga de Nix, sin sustituir la sesión de la
distro sino poniéndose al lado de ella:

```sh
bash nix/setup/bootstrap.sh     # activa .#pc y registra "Hyprland (Nix)"
```

Ver [`nix/setup/README.md`](nix/setup/README.md).

### Con paquetes de la distro

```sh
./install.sh                # informa qué falta, no toca nada
./install.sh --install      # instala dependencias y enlaza las configs
```

`install.sh` detecta Ubuntu, Debian y Arch. Solo `--install` modifica el
sistema, y pregunta antes de añadir un repositorio de terceros.

Para enlazar las configs sin instalar nada:

```sh
python3 setup.py            # se puede repetir; nunca borra
python3 setup.py --force    # además reapunta symlinks que apunten a otro sitio
```

## Atajos de teclado

`MOD` es la tecla **Súper** (Windows). Definidos en
[`hypr/modules/keysbindings.lua`](hypr/modules/keysbindings.lua).

### Aplicaciones

| Atajo | Acción |
|---|---|
| `MOD` + `Return` | Terminal (kitty) |
| `MOD` + `D` | Lanzador de aplicaciones (rofi) |
| `MOD` + `V` | Historial del portapapeles (cliphist + rofi) |
| `MOD` + `W` | Selector de fondos de pantalla (quickshell) |
| `MOD` + `O` | Captura de una región (hyprshot) |
| `MOD` + `Tab` | Bloquear la pantalla (hyprlock) |
| `MOD` + `` ` `` | Menú de apagado (wlogout) |
| `MOD` + `Shift` + `W` | Mostrar u ocultar la waybar |

### Capturas de pantalla

| Atajo | Acción |
|---|---|
| `MOD` + `Impr` | Pantalla completa → `~/Pictures/<marca de tiempo>.png` |
| `Impr` | Seleccionar región → `~/Pictures/<marca de tiempo>.png` |

### Ventanas

| Atajo | Acción |
|---|---|
| `MOD` + `Q` | Cerrar la ventana |
| `MOD` + `F` | Pantalla completa |
| `MOD` + `Shift` + `T` | Alternar flotante |
| `MOD` + `Espacio` | Alternar flotante, y centrarla al 70% de la pantalla |
| `MOD` + `H` `J` `K` `L` | Mover el foco: izquierda, abajo, arriba, derecha |
| `MOD` + `Shift` + `H` `J` `K` `L` | Desplazar la ventana en esa dirección |
| `MOD` + `Ctrl` + `H` `J` `K` `L` | Redimensionar en pasos de 10 px |
| `MOD` + arrastrar con botón izquierdo | Mover la ventana |
| `MOD` + arrastrar con botón derecho | Redimensionar la ventana |

### Escritorios

| Atajo | Acción |
|---|---|
| `MOD` + `1`…`0` | Ir al escritorio 1–10 |
| `MOD` + `Shift` + `1`…`0` | Enviar la ventana a ese escritorio |
| `MOD` + rueda del ratón | Escritorio anterior / siguiente |
| `MOD` + `S` | Mostrar u ocultar el escritorio especial (*magic*) |
| `MOD` + `Shift` + `S` | Enviar la ventana al escritorio especial |

### Sesión

| Atajo | Acción |
|---|---|
| `MOD` + `Shift` + `M` | Salir de Hyprland |
| `MOD` + `Shift` + `R` | Reiniciar el equipo |
| `MOD` + `Shift` + `Q` | Apagar el equipo |
| `MOD` + `Ctrl` + `S` | Suspender |

### Teclas multimedia y de hardware

Funcionan también con la pantalla bloqueada.

| Tecla | Acción |
|---|---|
| Subir / bajar volumen | `wpctl`, en pasos del 5% |
| Silenciar | Silencia la salida de audio |
| Silenciar micrófono | Silencia la entrada de audio |
| Brillo arriba / abajo | `brightnessctl`, en pasos del 5% |
| Reproducir / pausa | `playerctl` |
| Pista anterior / siguiente | `playerctl` |

### Desactivados

Están en el archivo pero comentados: `MOD` + `F` para el gestor de archivos
(choca con pantalla completa) y `MOD` + `O` para el selector de opacidad
(choca con la captura de región).

## Ajustes por máquina

Todo el repositorio es portable: sin rutas absolutas, sin nombres de monitor
fijos. Lo que depende de una máquina concreta va en un único sitio:

```sh
cp hypr/modules/local.lua.example hypr/modules/local.lua
```

`local.lua` está en `.gitignore` y se carga el último, así que sobrescribe los
valores compartidos. Sirve para nombres de conector, resoluciones, escala,
fondo de pantalla y para fijar escritorios a monitores concretos.

Sin ese archivo la config también funciona: `modules/monitors.lua` aplica una
regla comodín que vale para cualquier salida de vídeo.

## Dependencias

Ver [`packages/`](packages/README.md). En resumen: ninguna distro las trae
todas. Con Nix el problema casi desaparece;
[`packages/manual.md`](packages/manual.md) cubre lo que hay que compilar a
mano si vas por el camino de la distro.

## Estructura

| Ruta | |
|---|---|
| `hypr/` | Hyprland, en Lua, dividido en `modules/` |
| `waybar/`, `rofi/`, `dunst/`, `wlogout/` | Barra, lanzador, notificaciones, menú de apagado |
| `quickshell/hyprquickpaper/` | Selector de fondos (`MOD` + `W`) |
| `nvim/`, `btop/` | Editor y monitor del sistema |
| `scripts/`, `hypr/scripts/` | Scripts auxiliares |
| `packages/` | Manifiestos de dependencias por distro |
| `nix/` | Configuración de home-manager |

Los comentarios dentro del código siguen en inglés, que es el idioma de los
proyectos que configuran; esta documentación está en español.
