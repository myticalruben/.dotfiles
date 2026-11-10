# Hyprland desde Nix, en una máquina de verdad

Esta rama responde a una pregunta concreta: **¿puede Nix instalar también el
compositor, y no solo lo que corre encima?**

El repositorio decía que no, por una razón que sigue en pie: un compositor que
no arranca te deja sin sesión desde la que arreglarlo. La respuesta a eso no es
renunciar, es **no sustituir nada**. La entrada de Nix se registra al lado de
la de la distro, con otro nombre, y las dos aparecen en la pantalla de acceso.
Una sesión de Nix que no levante te cuesta un cierre de sesión, no el equipo.

## Una sola configuración

No hay variantes: `.#default` es la misma en una VM, un portátil y un PC. El
usuario y el home salen de `$USER` y `$HOME` al activar con `--impure`, y las
configs son symlinks al checkout (`~/.dotfiles`), así que se editan y se
recargan en caliente en cualquier máquina.

```sh
bash bootstrap.sh
```

## Poner en marcha

```sh
curl -fsSL https://raw.githubusercontent.com/myticalruben/.dotfiles/main/nix/setup/bootstrap.sh -o bootstrap.sh
less bootstrap.sh    # léelo antes: usa sudo en varios sitios
bash bootstrap.sh
```

Instala Nix si falta, clona el repositorio, te añade a los grupos `video`,
`input` y `render`, activa home-manager y registra la entrada de sesión.

Al terminar, cierra sesión y elige **"Mytical"** en el selector.

## Dónde se registra la sesión, y por qué se detecta

Este es el punto donde una ruta fija habría fallado en silencio: si el archivo
va al directorio equivocado, la entrada simplemente **no aparece**. Sin error,
sin aviso; solo una sesión que no está.

Y el directorio correcto no es el mismo en todas partes:

| Gestor | Directorio | Por qué |
|---|---|---|
| GDM | `/usr/local/share/wayland-sessions` | Es un programa GLib: pega `wayland-sessions` a los directorios de datos del sistema, que incluyen `/usr/local/share` |
| SDDM | su `SessionDir` | Lista explícita en `/etc/sddm.conf`; `/usr/local/share` no está por defecto |
| LightDM | su `sessions-directory` | Lista explícita en `/etc/lightdm/`; tampoco lo incluye |
| ninguno | — | Sin gestor no hace falta: lanza `hyprland-session` desde una TTY |

`install-hyprland-session` lo resuelve solo, preguntando a systemd cuál es el
gestor activo (`display-manager.service` es un alias del que esté activado, y
esa respuesta vale igual en Ubuntu, Mint y Arch). Para verlo sin tocar nada:

```sh
install-hyprland-session --dry-run     # no necesita root
install-hyprland-session --dir=/otra/ruta
```

Con GDM el archivo va a `/usr/local/share`, fuera del territorio de la distro.
Con SDDM y LightDM hay que escribir en `/usr/share/wayland-sessions`, que sí es
suyo; el nombre `hyprland-nix.desktop` es solo nuestro, así que no pisa nada.

## La GPU manda más que la distro

`nix/home.nix` fija `nixGLIntel`, que es Mesa. Con gráfica integrada de Intel o
AMD funciona igual en cualquier distro. **Con NVIDIA no**: hace falta
`nixGLNvidia` y que coincida exactamente con la versión del driver del host.
El script mira `lspci` y avisa si ve una NVIDIA, pero no lo arregla solo.

## Si vienes de probarlo en VirtualBox

Allí el script escribe `~/.config/hyprland-session.env` con
`LIBGL_ALWAYS_SOFTWARE=1`, porque VMSVGA no da una ruta de render por hardware
utilizable. En un equipo real eso solo te hace ir lento, así que al ejecutarlo
fuera de una VM el script detecta ese archivo y lo aparta a `.vm-backup`.

Ese archivo no es un apaño: es un punto de extensión del arranque de sesión.
Existe porque algunas variables tienen que estar puestas **antes** de que
Hyprland elija renderizador, que es antes de que lea cualquier config suya.

## Si no arranca

```sh
# Lo primero: lanzarlo desde una TTY (Ctrl+Alt+F3) da el error de verdad,
# en vez de devolverte a la pantalla de acceso sin explicación.
hyprland-session

# ¿Se registró donde debía?
install-hyprland-session --dry-run
ls -l "$(install-hyprland-session --dry-run | awk '/Directorio/{print $3}')"

# ¿Tienes acceso a DRM y a los dispositivos de entrada?
id -nG | tr ' ' '\n' | grep -E 'video|input|render'
ls -l /dev/dri/
```

### GPU emulada

En una VM con QEMU stdvga/bochs (PCI `1234:1111`) Hyprland no arranca aunque la
configuración sea correcta: no hay `/dev/dri/renderD128` y Mesa no tiene driver
para ese PCI, así que Aquamarine no encuentra EGLDevice. Con virtio-gpu
(Proxmox: Display=VirGL) sí arranca; si el display no expone virgl, Mesa cae a
`kms_swrast` y la sesión va por software, pero funciona.

## Coste

Medido: **3,8 GiB** en la única configuración, con Hyprland, brave, thunar y
hyprlock incluidos. Hyprland cuesta unos **300 MiB** en la práctica, aunque su
closure aislado sea mayor, porque comparte Mesa y Qt con lo que ya estaba.
