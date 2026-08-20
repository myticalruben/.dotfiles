# Probar Hyprland desde Nix en una VM

Esta rama responde a una pregunta concreta: **¿puede Nix instalar también el
compositor, y no solo lo que corre encima?**

El repositorio decía que no, y por una razón sensata que sigue en pie: un
compositor que no arranca te deja sin sesión desde la que arreglarlo. Una VM
elimina justo ese riesgo, así que es donde toca comprobarlo.

## Qué prueba exactamente

La configuración `vm` del flake se diferencia de la diaria en dos cosas, y
ambas son deliberadas:

| | diaria (`.#ruben`) | VM (`.#vm`) |
|---|---|---|
| Hyprland | paquete de Ubuntu | Nix, envuelto en nixGL |
| Configs | symlink al checkout, editables | copiadas al `/nix/store`, solo lectura |

Lo segundo es lo que convierte esto en una prueba de verdad. Con las configs
inmutables no hay forma de "arreglarlo a mano hasta que arranque": si la sesión
levanta, levanta desde el flake y nada más. Tu `hypr/modules/local.lua` ni
siquiera llega a la VM —está en `.gitignore`, así que el flake no lo copia—, y
la VM cae en la regla catch-all de `monitors.lua`, que es exactamente lo que
haría una máquina nueva.

## Antes de empezar: ajustes de VirtualBox

| Ajuste | Valor | Por qué |
|---|---|---|
| Controlador gráfico | VMSVGA | Es el único que expone un dispositivo DRM utilizable |
| Aceleración 3D | **desactivada** | Con ella activada Hyprland suele morir al elegir renderizador; el camino por software es más fiable |
| Memoria de vídeo | 128 MB | El máximo; por debajo se ven artefactos |
| RAM | 4 GB o más | Nix descarga y descomprime bastante |
| Disco | 25 GB o más | El closure ronda los 4,7 GiB, más Ubuntu |

Necesitas Ubuntu **con escritorio** (que trae GDM). Sobre una imagen de
servidor no hay pantalla de acceso donde elegir la sesión, y habría que lanzar
`hyprland-session` a mano desde una TTY.

## Poner en marcha

Dentro de la VM:

```sh
curl -fsSL https://raw.githubusercontent.com/myticalruben/.dotfiles/feat/hyprland-from-nix/nix/vm/bootstrap.sh -o bootstrap.sh
less bootstrap.sh    # léelo antes de ejecutarlo, hace cosas con sudo
bash bootstrap.sh
```

El script instala Nix si falta, clona el repositorio, te añade a los grupos
`video`, `input` y `render`, activa `.#vm` y registra la entrada de sesión.

**Se niega a ejecutarse fuera de una VM.** Activar la configuración `vm` en tu
equipo real dejaría `~/.config` apuntando a rutas de solo lectura y te quitaría
el flujo de edición en caliente; molesto de deshacer, fácil de evitar. Si aun
así lo quieres, `--force`.

Al terminar, cierra sesión y elige **"Hyprland (Nix)"** en el selector de
sesión de GDM. La entrada de Ubuntu sigue ahí, intacta.

## El renderizado va por software, y es lo esperado

VirtualBox no ofrece una GPU con la que Hyprland pueda renderizar por hardware
de forma fiable, así que el script escribe `~/.config/hyprland-session.env`
con `LIBGL_ALWAYS_SOFTWARE=1`. La sesión va lenta. Da igual: lo que se prueba
aquí es que **arranca y se configura sola**, no cuánto rinde.

Ese archivo es un punto de extensión del propio arranque de sesión, no un
apaño para la VM. Existe porque algunas variables tienen que estar puestas
*antes* de que Hyprland elija renderizador, que es antes de que lea cualquier
config suya. Y con las configs inmutables no se puede dejar nada dentro de
`~/.config/hypr`, porque es una ruta del store.

## Qué mirar si no arranca

```sh
# ¿Existe la entrada y apunta a donde debe?
cat /usr/local/share/wayland-sessions/hyprland-nix.desktop

# ¿El binario está donde dice la entrada?
ls -l ~/.nix-profile/bin/hyprland-session

# Arrancarlo a mano desde una TTY (Ctrl+Alt+F3) da el error de verdad,
# en vez de devolverte a la pantalla de acceso sin explicación:
hyprland-session

# ¿Tienes acceso a DRM y a los dispositivos de entrada?
id -nG | tr ' ' '\n' | grep -E 'video|input|render'
ls -l /dev/dri/
```

## Coste

Medido, no estimado: el closure pasa de **4,4 GiB** (configuración diaria) a
**4,7 GiB** con el compositor incluido. Hyprland cuesta unos **300 MiB** en la
práctica, aunque su closure aislado sean 3,0 GiB, porque comparte Mesa, Qt y
buena parte del resto con lo que ya estaba.

## Si sale bien

Pasar tu equipo real a esto **no** significa desinstalar el Hyprland de Ubuntu.
La entrada de Nix se instala en `/usr/local/share/wayland-sessions` con otro
nombre, junto a la de la distro. Las dos aparecen en la pantalla de acceso, y
una sesión de Nix que no levante te cuesta un cierre de sesión, no la máquina.
