# Auditoría de assets y licencias — Mytical V1.0

> **Estado:** auditoría de solo lectura. No se modificó ningún asset, tema ni
> configuración visual.
> **Fecha:** 2026-11-17
> **Rama:** `feat/mytical-v1` · **HEAD de cierre:** `113a10b`
> **Alcance:** Plymouth, SDDM, `Wallpapers/`, `wlogout/icons/`, `kitty/`,
> fuentes y cualquier otro icono/arte versionado en el repositorio.
> **Método:** inspección de archivos, metadatos EXIF/PNG, revisión visual y
> comparación de blobs Git con los repositorios upstream. Los hashes se
> calcularon sobre `7959e4c`; entre ese commit y `113a10b` no cambió ningún
> asset.
> **Aviso:** este documento es un inventario técnico, no asesoría legal.

---

## Aviso de marca: Mytical no es Ubuntu oficial

**Mytical es un proyecto independiente basado en Ubuntu 26.04. No está
afiliado, patrocinado ni respaldado por Canonical Ltd.** "Ubuntu",
"Canonical" y el logo "Circle of Friends" son marcas de Canonical Ltd.

- **No se usarán logos oficiales de Ubuntu/Canonical** en SDDM, Plymouth,
  wallpapers, iconos, instalador, `os-release` gráfico ni material promocional.
- El nombre "Ubuntu" se usa únicamente para describir la base técnica
  ("basada en Ubuntu 26.04"), nunca para sugerir una edición oficial.
- No se encontró ningún archivo con el logo oficial de Ubuntu en las rutas
  auditadas. El wordmark **MYTICAL** es propio y no incorpora el logo de
  Ubuntu ni el de CachyOS.
- Antes de publicar hay que revisar la
  [política de marcas de Canonical](https://canonical.com/legal/trademarks) y
  validar el nombre comercial "Mytical". Esa revisión está fuera del alcance de
  esta auditoría.

El aviso existente en [`THIRD_PARTY_NOTICES`](../../THIRD_PARTY_NOTICES#L10-L11)
es correcto, pero debe ampliarse con el detalle de esta auditoría.

---

## 1. Veredicto

**No apto para publicar una ISO con los assets actuales.** Hay seis
bloqueos P0:

1. **Los 41 throbbers de Plymouth son copias byte a byte del tema de CachyOS**,
   cuyo repositorio no declara licencia. No hay permiso documentado para
   redistribuirlos.
2. **Los 22 wallpapers no tienen licencia, autor ni fuente.** Varios son arte
   de personajes de anime reconocibles y uno es una fotografía real con EXIF de
   cámara y RAW. No deberían publicarse sin derechos.
3. **Los 5 iconos de `wlogout` no tienen procedencia ni licencia.** Es barato
   reemplazarlos, pero hoy no hay base para distribuirlos.
4. **La animación propia de Plymouth no tiene licencia declarada** y el README
   la describe como "estilo CachyOS". No se encontraron archivos idénticos al
   upstream, pero falta la cadena de autoría y la licencia de salida.
5. **El tema SDDM es GPL-3.0-or-later y está correctamente atribuido**, pero la
   ISO debe incluir su `LICENSE`, los avisos de copyright y la fuente
   correspondiente. Si se omite, la distribución puede incumplir la GPL.
6. **La licencia raíz del proyecto sigue sin existir.** Sin términos para el
   código y el arte propios, no hay una base clara para publicar la ISO.

| Clasificación | Archivos | Detalle |
|---|---:|---|
| **OFL-1.1** | 1 (+ `OFL.txt`) | Audiowide Regular |
| **GPL-3.0-or-later** | 18 | 8 QML, 7 SVG, `LICENSE`, `mytical.conf`, `metadata.desktop` |
| **Propio (presunto), sin licencia** | 88 | frames `animation-00` a `animation-87` |
| **Desconocido / sin licencia** | 69 | 41 throbber, 22 wallpapers, 5 iconos wlogout, 1 config Plymouth |
| **CC0** | 0 | No hay ningún asset CC0 identificado |

> "Propio" aquí significa que la autoría corresponde al repositorio según sus
> commits/README y que no se encontró una copia byte a byte de un upstream.
> **No significa que exista una licencia que permita redistribuirlo:** falta la
> declaración expresa. Ver [P0-05](#6-tabla-accionable-p0p1).

---

## 2. Metodología y evidencia

- **Comparación de blobs Git:** se calculó `git hash-object` de cada archivo y
  se comparó con el blob SHA publicado por GitHub en el árbol del upstream.
  Esto detecta copias byte a byte, no solo similitudes visuales.
- **Metadatos:** se leyeron los chunks `tEXt`/`tIME` de los PNG, los tags EXIF
  de los JPEG y la tabla `name` del TTF. También se usó `ffprobe` para
  dimensiones y formato real.
- **Revisión visual:** se compusieron los PNG transparentes sobre fondo oscuro
  y se generó una hoja de contactos de los 22 wallpapers y de los 5 iconos de
  wlogout.
- **Sin modificaciones:** no se reescribió, recodificó ni movió ningún asset.

Resultados de identidad con upstream:

| Grupo | Comparación | Resultado |
|---|---|---|
| Throbber Plymouth | 41 archivos vs. [CachyOS/plymouth-theme](https://github.com/CachyOS/plymouth-theme) | **41/41 idénticos** |
| Animación Plymouth | 88 frames vs. el mismo upstream | **0/88 idénticos** (formato 640×260 propio) |
| SDDM | [Main.qml](../../ubuntu/sddm/theme/Main.qml), 7 componentes, 7 SVG y `LICENSE` vs. [Keyitdev/sddm-astronaut-theme](https://github.com/Keyitdev/sddm-astronaut-theme) | **16/16 idénticos** |

El upstream de CachyOS **no declara licencia**: la API de GitHub devuelve
`license: null` y el repositorio no contiene un archivo `LICENSE`. La ausencia
de licencia no equivale a permiso; salvo autorización expresa que no consta,
no hay base documentada para redistribuir esos archivos.

---

## 3. Inventario y clasificación

### 3.1 Plymouth

Archivos: [`ubuntu/plymouth/mytical/`](../../ubuntu/plymouth/mytical/) ·
README: [`ubuntu/plymouth/README.md`](../../ubuntu/plymouth/README.md#L3-L10)

| Asset | Archivos concretos | Cantidad | Licencia | Evidencia | Estado |
|---|---|---:|---|---|---|
| Frames de animación | [`animation-00`](../../ubuntu/plymouth/mytical/animation-00.png), [`animation-20`](../../ubuntu/plymouth/mytical/animation-20.png), [`animation-44`](../../ubuntu/plymouth/mytical/animation-44.png), [`animation-87`](../../ubuntu/plymouth/mytical/animation-87.png) y el resto de `animation-00`–`animation-87` | 88 PNG 640×260 | **Propio (presunto), sin licencia** | 0/88 blobs idénticos a CachyOS; wordmark MYTICAL propio; el README dice "estilo CachyOS" y "se deja el comportamiento de CachyOS" | **P1**: declarar autoría y licencia; **P0** si se usó material fuente de CachyOS |
| Throbber | [`throbber-00`](../../ubuntu/plymouth/mytical/throbber-00.png), [`throbber-20`](../../ubuntu/plymouth/mytical/throbber-20.png), [`throbber-40`](../../ubuntu/plymouth/mytical/throbber-40.png) y el resto de `throbber-00`–`throbber-40` | 41 PNG 65×65 | **Desconocido — copia de CachyOS, sin licencia** | **41/41 blobs idénticos** al upstream; el [README](../../ubuntu/plymouth/README.md#L9) dice "el throbber azul de CachyOS" | **P0**: retirar o reemplazar |
| Config Plymouth | [`mytical.plymouth`](../../ubuntu/plymouth/mytical/mytical.plymouth#L1-L20) | 1 | **Desconocido — derivado de CachyOS, sin licencia** | Misma estructura y claves que `cachyos-bootanimation.plymouth`; el README dice que se deja el comportamiento de CachyOS | **P0**: reescribir desde cero o pedir permiso |
| Fuente del wordmark | [`Audiowide-Regular.ttf`](../../ubuntu/plymouth/fonts/Audiowide-Regular.ttf) + [`OFL.txt`](../../ubuntu/plymouth/fonts/OFL.txt) | 1 TTF | **OFL-1.1** | Copyright (c) 2012 Brian J. Bonislawsky DBA Astigmatic; el TTF declara familia `Audiowide`; el texto OFL 1.1 está completo | **OK**. Si se redistribuye el TTF, conservar `OFL.txt`; una versión modificada no puede usar el nombre reservado "Audiowide" |
| Instalador | [`install.sh`](../../ubuntu/plymouth/install.sh) | 1 | Código propio, sin licencia raíz | Copia solo `mytical/`; **no copia `fonts/`**, así que el TTF no viaja al initramfs | P1: incluir aviso si el paquete de branding incorpora la fuente |

**Riesgo del throbber:** un spinner geométrico simple podría no superar el
umbral de originalidad en algunas jurisdicciones, pero **no hay que asumirlo**:
el archivo es una copia exacta de un repositorio sin licencia. El coste de
reemplazarlo por un spinner propio es mínimo comparado con una reclamación de
retirada o una auditoría de licencias fallida.

**Riesgo de la animación:** los frames no son copias byte a byte del upstream,
pero el README declara inspiración/derivación de CachyOS. Si se generaron desde
frames de CachyOS, la obra derivada arrastra la falta de licencia del upstream.
Hay que documentar el proceso de generación y, si hubo material fuente, obtener
permiso o regenerarla desde cero. El wordmark usa glifos rasterizados de
Audiowide, lo cual está permitido por la OFL; no se distribuye el TTF con la
animación.

### 3.2 SDDM

Archivos: [`ubuntu/sddm/theme/`](../../ubuntu/sddm/theme/) ·
Upstream: [Keyitdev/sddm-astronaut-theme](https://github.com/Keyitdev/sddm-astronaut-theme)

| Asset | Archivos concretos | Licencia | Evidencia | Estado |
|---|---|---|---|---|
| QML principal y componentes | [`Main.qml`](../../ubuntu/sddm/theme/Main.qml#L1-L4), [`Clock.qml`](../../ubuntu/sddm/theme/Components/Clock.qml#L1-L4), [`Input.qml`](../../ubuntu/sddm/theme/Components/Input.qml#L1-L4), [`LoginForm.qml`](../../ubuntu/sddm/theme/Components/LoginForm.qml#L1-L4), [`SessionButton.qml`](../../ubuntu/sddm/theme/Components/SessionButton.qml#L1-L4), [`SystemButtons.qml`](../../ubuntu/sddm/theme/Components/SystemButtons.qml#L1-L4), [`VirtualKeyboard.qml`](../../ubuntu/sddm/theme/Components/VirtualKeyboard.qml#L1-L4), [`VirtualKeyboardButton.qml`](../../ubuntu/sddm/theme/Components/VirtualKeyboardButton.qml#L1-L4) | **GPL-3.0-or-later** | Cabecera: "Copyright (C) 2022-2025 Keyitdev", basado en `sddm-sugar-dark` de MarianArlt; 8/8 idénticos al upstream | **OK** si se conserva la licencia y la fuente |
| Iconos SVG | [`Hibernate.svg`](../../ubuntu/sddm/theme/Assets/Hibernate.svg), [`Password.svg`](../../ubuntu/sddm/theme/Assets/Password.svg), [`Password2.svg`](../../ubuntu/sddm/theme/Assets/Password2.svg), [`Reboot.svg`](../../ubuntu/sddm/theme/Assets/Reboot.svg), [`Shutdown.svg`](../../ubuntu/sddm/theme/Assets/Shutdown.svg), [`Suspend.svg`](../../ubuntu/sddm/theme/Assets/Suspend.svg), [`User.svg`](../../ubuntu/sddm/theme/Assets/User.svg) | **GPL-3.0-or-later** según el repo upstream | 7/7 idénticos al upstream; metadatos internos vacíos o de Illustrator/Inkscape, sin autoría individual | **P1**: la procedencia individual no está documentada; verificar o sustituir por SVG propios |
| Texto de licencia | [`LICENSE`](../../ubuntu/sddm/theme/LICENSE) | **GPL-3.0** (texto íntegro) | Idéntico al `LICENSE` upstream; 35.149 bytes | **OK**. Debe viajar en la ISO y en el paquete |
| Config del tema | [`Themes/mytical.conf`](../../ubuntu/sddm/theme/Themes/mytical.conf#L1-L5) | **GPL-3.0-or-later** (derivado) | 72 líneas de diff respecto de `Themes/astronaut.conf`; conserva la estructura y comentarios del original | **OK** con aviso GPL; es una obra derivada |
| Metadatos | [`metadata.desktop`](../../ubuntu/sddm/theme/metadata.desktop#L1-L15) | **GPL-3.0-or-later** (derivado) | `Author=keyitdev`, `License=GPL-3.0-or-later`; nombre y `Theme-Id` cambiados por Mytical | **OK**; mantener `Author`, `Website` y `License` |
| Fondo del greeter | [`Backgrounds/`](../../ubuntu/sddm/theme/Backgrounds/) (vacío) | **Desconocido en tiempo de ejecución** | `mytical-sddm-sync` copia el wallpaper del usuario; si no hay, usa [`01.png`](../../Wallpapers/01.png) | **P0** por arrastre: el fondo por defecto es un wallpaper sin licencia |

**GPL:** el tema se distribuye bajo GPL-3.0-or-later. Esto es compatible con
un proyecto libre, pero impone obligaciones concretas: incluir el texto de la
licencia, conservar los avisos de copyright, entregar la fuente correspondiente
(y las modificaciones de Mytical: `mytical.conf` y `metadata.desktop`) y no
añadir restricciones adicionales sobre el tema. La licencia raíz del proyecto
no puede contradecir esto. Si Mytical quisiera distribuir su propio código como
propietario, el tema SDDM debe quedar claramente separado como componente GPL.

**Fuentes del tema:** `mytical.conf` pide `Font="Open Sans"`; no hay TTF de
Open Sans en el repositorio. Se resuelve con la fuente del sistema
(`fonts-open-sans` o equivalente), cuya licencia gestiona el paquete de Ubuntu.
No es un asset redistribuido aquí, pero debe figurar como dependencia.

### 3.3 Wallpapers

Archivos: [`Wallpapers/`](../../Wallpapers/) · 22 imágenes, ~40 MB.
Todos están versionados y `setup.py` enlaza la carpeta completa en
`~/Pictures/Wallpapers` ([`setup.py#L53`](../../setup.py#L53)).

**Ninguno tiene licencia, autor, fuente ni atribución.** No hay un `LICENSE`,
un `CREDITS` ni metadatos que permitan identificar al titular. Por tanto, la
clasificación de todos es **Desconocido / sin licencia**.

| Archivo | Dimensiones | Señal de procedencia | Riesgo | Acción |
|---|---|---:|---|---|
| [`0.png`](../../Wallpapers/0.png) | 1536×1024 | Flores; sin metadatos | Medio | Retirar o sustituir (P0) |
| [`01.png`](../../Wallpapers/01.png) | 1920×1050 | **PNG que en realidad contiene JPEG**; sin metadatos | Medio | Retirar o sustituir (P0) |
| [`02.jpg`](../../Wallpapers/02.jpg) | 2460×1700 | Arte de personaje de anime; sin autoría | **Alto** | Retirar o sustituir (P0) |
| [`03.jpg`](../../Wallpapers/03.jpg) | 3840×2160 | Ciudad nocturna; solo perfil ICC genérico | Medio | Retirar o sustituir (P0) |
| [`04.jpg`](../../Wallpapers/04.jpg) | 1920×1080 | Figura; sin metadatos | Medio | Retirar o sustituir (P0) |
| [`05.jpg`](../../Wallpapers/05.jpg) | 4592×2584 | Montaña; sin metadatos | Medio | Retirar o sustituir (P0) |
| [`06.jpg`](../../Wallpapers/06.jpg) | 3840×1477 | EXIF de 6 entradas; sin autor | Medio | Retirar o sustituir (P0) |
| [`07.jpg`](../../Wallpapers/07.jpg) | 1920×1080 | `gd-jpeg`; sin autor | Medio | Retirar o sustituir (P0) |
| [`08.jpg`](../../Wallpapers/08.jpg) | 1441×1800 | Interior; sin metadatos | Medio | Retirar o sustituir (P0) |
| [`1.png`](../../Wallpapers/1.png) | 3840×2160 | Carretera nevada; sin metadatos | Medio | Retirar o sustituir (P0) |
| [`10.jpg`](../../Wallpapers/10.jpg) | 2560×1440 | Eclipse; sin autor | Medio | Retirar o sustituir (P0) |
| [`13.jpg`](../../Wallpapers/13.jpg) | 1920×1045 | Bosque; sin metadatos | Medio | Retirar o sustituir (P0) |
| [`3.jpg`](../../Wallpapers/3.jpg) | 2500×1322 | Arte de fantasía oscura; sin autoría | **Alto** | Retirar o sustituir (P0) |
| [`6.jpg`](../../Wallpapers/6.jpg) | 5120×2880 | **EXIF real:** FUJIFILM X-T3, RAW `DSCF3466.RAF`, Adobe Lightroom Classic 8.4.1, fecha 2019-09-19 | **Alto** | Retirar o sustituir (P0) |
| [`9.jpg`](../../Wallpapers/9.jpg) | 2560×1440 | Planeta; sin metadatos | Medio | Retirar o sustituir (P0) |
| [`rn.jpg`](../../Wallpapers/rn.jpg) | 3840×2160 | `gd-jpeg`; sin autor | Medio | Retirar o sustituir (P0) |
| [`w0.jpg`](../../Wallpapers/w0.jpg) | 3840×2160 | Procesado con Photoshop 26 y Topaz Photo AI; sin autor | **Alto** | Retirar o sustituir (P0) |
| [`w1.jpg`](../../Wallpapers/w1.jpg) | 1920×1080 | Paisaje; sin metadatos | Medio | Retirar o sustituir (P0) |
| [`w2.jpg`](../../Wallpapers/w2.jpg) | 1920×1080 | Rostro de anime; sin autoría | **Alto** | Retirar o sustituir (P0) |
| [`w3.jpg`](../../Wallpapers/w3.jpg) | 3840×2160 | Ciudad; sin metadatos | Medio | Retirar o sustituir (P0) |
| [`w4.png`](../../Wallpapers/w4.png) | 1920×1080 | Bosque; sin metadatos | Medio | Retirar o sustituir (P0) |
| [`ww.jpg`](../../Wallpapers/ww.jpg) | 2048×1448 | **Personaje reconocible como Rei Ayanami (*Neon Genesis Evangelion*)**; sin autoría | **Crítico** | Retirar del repo/ISO y sustituir (P0) |

Notas:

- `ww.jpg` es un fan art o ilustración derivada de una franquicia ajena. Los
  derechos del personaje pertenecen a sus titulares; no debería distribuirse sin
  licencia, aunque la ilustración sea de un tercero.
- `6.jpg` no es arte generado: los metadatos prueban una fotografía real
  procesada desde RAW. Es el caso más claro de obra ajena sin licencia.
- `02.jpg`, `3.jpg` y `w2.jpg` contienen personajes/estilos de anime que no se
  pueden tratar como arte genérico. Aunque no se identifique la franquicia, la
  falta de autoría no permite acreditar derechos para publicarlos.
- `01.png` tiene extensión `.png` pero contenido JPEG. No es un problema legal,
  pero rompe la coherencia del manifiesto y conviene corregirlo al reemplazar.
- Los wallpapers se enlazan en `~/Pictures/Wallpapers`, no se copian a
  `/usr/share`. Aun así, **el repositorio público ya los distribuye** y el
  instalador/ISO previsto los incluiría; el riesgo existe hoy, no solo en la ISO.

### 3.4 wlogout

Archivos: [`wlogout/icons/`](../../wlogout/icons/) · 5 PNG 512×512.

`wlogout/style.css` los referencia como fondo de cada botón:
[`style.css#L50-L66`](../../wlogout/style.css#L50-L66).

| Asset | Archivo | Licencia | Evidencia | Estado |
|---|---|---|---|---|
| Lock | [`lock.png`](../../wlogout/icons/lock.png) | **Desconocido** | Sin `tEXt`/`tIME`; candado blanco sobre transparente | P0: sustituir |
| Logout | [`logout.png`](../../wlogout/icons/logout.png) | **Desconocido** | Sin metadatos; flecha de salida | P0: sustituir |
| Reboot | [`reboot.png`](../../wlogout/icons/reboot.png) | **Desconocido** | Sin metadatos; flecha circular | P0: sustituir |
| Shutdown | [`shutdown.png`](../../wlogout/icons/shutdown.png) | **Desconocido** | Sin metadatos; símbolo de encendido | P0: sustituir |
| Suspend | [`suspend.png`](../../wlogout/icons/suspend.png) | **Desconocido** | Sin metadatos; pausa en círculo | P0: sustituir |

No se encontró atribución en `wlogout/layout`, `style.css` ni en los commits
que añadieron los iconos. Visualmente son coherentes con un set de iconos
genérico (candado, salida, recarga, encendido, pausa), pero **no se identificó
el set ni su licencia**, así que no se puede afirmar que sean CC0 ni GPL.

Sustitución recomendada, con licencia verificable:

- [Lucide](https://lucide.dev/) — licencia **ISC**; iconos `lock`, `log-out`,
  `rotate-ccw`, `power`, `pause`.
- [Font Awesome Free](https://fontawesome.com/license/free) — iconos **CC BY
  4.0**; requiere atribución visible y no redistribuir los SVG como si fueran
  propios.

Cualquiera de las dos opciones debe ir con su `LICENSE`/`NOTICE` y el nombre
del set en `THIRD_PARTY_NOTICES`.

### 3.5 Kitty, fuentes y otros

| Archivo | Tipo | Licencia | Nota |
|---|---|---|---|
| [`kitty/kitty.conf`](../../kitty/kitty.conf) | Config | Código propio, sin licencia raíz | No incluye arte. `font_family JetBrainsMono Nerd Font` |
| [`kitty/theme.py`](../../kitty/theme.py) | Código | Código propio, sin licencia raíz | Genera la paleta; no es un asset |
| [`kitty/theme.sh`](../../kitty/theme.sh) | Código | Código propio, sin licencia raíz | Idem |
| [`wlogout/style.css`](../../wlogout/style.css#L50-L66) | Config | Código propio, sin licencia raíz | Referencia los 5 PNG desconocidos |
| [`wlogout/layout`](../../wlogout/layout) | Config | Código propio, sin licencia raíz | Sin arte |
| [`distro/branding/`](../../distro/branding/) | Directorio | — | **Vacío**; no hay `branding.conf` ni logo oficial de Ubuntu. No hay nada que auditar aquí todavía |

**JetBrains Mono:** no está en el repositorio. Se obtiene de
`fonts-nerd-jetbrains-mono` (APT) o `nerd-fonts.jetbrains-mono` (Nix), según
[`distro/ownership.json`](../../distro/ownership.json). JetBrains Mono se
publica bajo OFL-1.1; si la ISO empaqueta el TTF, debe incluir su licencia y
atribución. Si solo se declara como dependencia, la obligación la cubre el
paquete de la distro base.

**Fuentes del sistema referenciadas, no redistribuidas:**

- `mytical.plymouth` usa `Font=Ubuntu 12` y `TitleFont=Ubuntu Light 30`
  ([`mytical.plymouth#L7-L8`](../../ubuntu/plymouth/mytical/mytical.plymouth#L7-L8)).
  Son fuentes del sistema Ubuntu, no archivos del repo.
- `mytical.conf` usa `Font="Open Sans"`; tampoco se incluye en el repo.

No son logos ni assets de marca; no bloquean por sí mismas, pero deben
declararse como dependencias si el paquete de branding las instala.

---

## 4. Qué falta exactamente para publicar lo desconocido

| Activo | Licencia que falta | Atribución que falta | Salida aceptable |
|---|---|---|---|
| Throbber `throbber-00`–`throbber-40` | Permiso escrito de CachyOS o una licencia SPDX clara; hoy no existe `LICENSE` upstream | "CachyOS/plymouth-theme" y autor, si se obtiene permiso | **Preferido:** spinner propio (diseño nuevo) con licencia del proyecto. **Alternativa:** permiso escrito y atribución en `THIRD_PARTY_NOTICES` |
| `mytical.plymouth` | Licencia del config upstream o reescritura independiente | CachyOS si se mantiene la derivación | Reescribir el `.plymouth` desde la documentación de Plymouth; es corto y elimina la duda |
| 22 wallpapers | Licencia por archivo, autor y URL de origen | Autor, título y URL, o "propio" con licencia del proyecto | **Retirar los 22** del repo/ISO y publicar un set propio o CC0 con manifiesto y checksums. Para `ww.jpg`, la salida segura es retirarlo o licenciarlo con el titular de Evangelion |
| 5 iconos wlogout | Licencia del set original | Nombre del set, autor y URL | Reemplazar por Lucide (ISC) o Font Awesome Free (CC BY 4.0) con aviso; o dibujar 5 SVG propios |
| Frames de animación | Declaración de autoría y licencia de salida | "Ruben Alexander" o el autor que corresponda | Añadir `LICENSE`/`ASSETS-LICENSE` con SPDX y un párrafo de autoría; confirmar que no se usaron frames de CachyOS |
| SVG del tema SDDM | Ya cubiertos por GPL-3.0-or-later del upstream, pero falta la procedencia individual | Keyitdev / upstream | Verificar que el upstream tenía derecho a relicenciarlos; si no, sustituir por SVG propios |
| Wordmark MYTICAL | No es un asset de terceros, pero no hay licencia ni búsqueda de marca | Autoría del repo | Declaración de copyright/licencia; búsqueda de anterioridad de "Mytical" antes de registrar/promocionar |

---

## 5. Riesgo legal concreto que bloquea la ISO

| Riesgo | Por qué bloquea | Severidad | Mitigación |
|---|---|---|---|
| Throbber copiado de CachyOS sin licencia | Redistribución de obra ajena sin permiso; el upstream no concede licencia | **P0 — bloqueante** | Retirar y reemplazar; no esperar a una respuesta de CachyOS para la V1.0 |
| Wallpapers sin licencia, con personajes y una foto real | Derechos de autor de terceros; una ISO es distribución pública y puede atraer reclamaciones | **P0 — bloqueante** | Retirar los 22; publicar solo un set propio/CC0 con trazabilidad |
| Iconos wlogout sin licencia | Distribución de iconos sin permiso; riesgo bajo pero evitable | **P0 — bloqueante** (si van en la ISO) | Sustituir por Lucide/FA Free con aviso |
| Animación sin licencia declarada | No hay permiso explícito de reproducción/redistribución, aunque sea propia | **P0 — bloqueante documental** | Añadir licencia de assets y confirmar proceso de generación |
| Tema SDDM GPL sin avisos/fuente en la ISO | La GPL exige licencia, copyright y fuente correspondiente; omitirlos puede constituir incumplimiento | **P0 — bloqueante de empaquetado** | Incluir `LICENSE`, cabeceras y fuente; probarlo en el manifiesto de la ISO |
| Licencia raíz ausente | Sin términos para el código/arte propio, nadie puede reutilizarlo y el proyecto no puede declarar una licencia coherente | **P0 — bloqueante de release** | Añadir `LICENSE` raíz + licencia de assets; revisar compatibilidad GPL |
| Marca Ubuntu | Sugerir afiliación oficial puede infringir la política de marcas | **P1 — evitar** | Aviso visible, sin logos, nombre descriptivo; revisión legal de la política |
| Marca "Mytical" | Posible conflicto de marca no verificado | **P1 — verificar** | Búsqueda de anterioridad antes de publicar la ISO |

**Conclusión:** la ISO no debería publicarse mientras existan el throbber de
CachyOS, los 22 wallpapers y los iconos de wlogout sin licencia. La animación y
la licencia raíz son bloqueos documentales que se pueden cerrar en el mismo
ciclo. El tema SDDM no bloquea por su licencia, pero sí por cómo se empaqueta.

---

## 6. Tabla accionable P0/P1

**Roles de decisión** (no se inventan personas que no constan en el repo):

- **Owner / Release:** Ruben Alexander, owner de `myticalruben/.dotfiles`
  (config de Git y remoto).
- **Legal:** asesoría legal externa, **aún no designada**. Las decisiones de
  licencia y marca requieren su firma; hasta entonces, el owner no debe
  publicar.
- **Branding:** responsable de branding, **aún no designado**; por defecto
  recae en el owner.
- **Empaquetado:** quien construya `mytical-branding`/la ISO (hoy, el owner).

| ID | Pri | Activo | Acción concreta | Responsable de decidir | Criterio de cierre |
|---|---|---|---|---|---|
| **P0-01** | P0 | Throbber CachyOS (41 PNG) | Retirar `throbber-*.png` del repo y del tema. Sustituir por un spinner propio (nuevo diseño, licencia del proyecto) o lograr permiso escrito de CachyOS | Owner + Legal | `git hash-object` de cada throbber nuevo no coincide con ningún blob de CachyOS; hay licencia/atribución en el repo |
| **P0-02** | P0 | `mytical.plymouth` derivado | Reescribir el archivo desde la documentación de Plymouth, sin copiar la estructura de CachyOS; o permiso escrito | Owner + Legal | Diff contra upstream sin coincidencias sustanciales; config propio documentado |
| **P0-03** | P0 | 22 wallpapers | Retirar los 22 del repo público y de la ISO. Publicar un set nuevo propio/CC0 (mínimo 3–5 imágenes) con manifiesto: archivo, autor, licencia, URL, SHA-256 | Owner + Legal | 0 wallpapers sin licencia; `ww.jpg`, `02.jpg`, `6.jpg` y `w0.jpg` fuera; manifiesto completo |
| **P0-04** | P0 | 5 iconos wlogout | Sustituir por Lucide (ISC) o Font Awesome Free (CC BY 4.0), o dibujar SVG propios. Añadir `LICENSE`/`NOTICE` | Owner (Branding) | 5 iconos nuevos con licencia y atribución; `style.css` apunta a ellos |
| **P0-05** | P0 | Licencia raíz y de assets | Elegir licencia de código (compatible con GPL del tema) y licencia de arte propio; crear `LICENSE` raíz y `LICENSE-ASSETS`/`ASSETS.md` con SPDX | Owner + Legal | `LICENSE` y licencia de assets presentes; `THIRD_PARTY_NOTICES` coherente; SDDM sigue en GPL-3.0-or-later |
| **P0-06** | P0 | Empaquetado GPL SDDM | Incluir `ubuntu/sddm/theme/LICENSE`, cabeceras de copyright y fuente correspondiente en el paquete/ISO; no imponer restricciones extra | Owner + Empaquetado + Legal | `dpkg -c` muestra `LICENSE` y fuente; aviso GPL en la ISO; revisión legal conforme |
| **P1-01** | P1 | SVG SDDM | Verificar la procedencia individual de los 7 SVG; si no hay evidencia, sustituirlos por SVG propios | Branding | 7 SVG con autoría/licencia documentada o reemplazados |
| **P1-02** | P1 | Frames de animación | Añadir declaración de autoría y licencia; documentar que no se usaron frames de CachyOS. Si se usaron, regenerar | Owner + Legal | Licencia de assets + nota de proceso; 0 blobs de CachyOS |
| **P1-03** | P1 | Audiowide | Mantener `OFL.txt`; no renombrar la fuente reservada; incluir aviso si el TTF viaja en la ISO | Empaquetado | `OFL.txt` junto al TTF; aviso en `THIRD_PARTY_NOTICES` |
| **P1-04** | P1 | Fuentes externas | Declarar Open Sans, Ubuntu Font y JetBrains Mono como dependencias; si se empaquetan, incluir sus licencias | Empaquetado | Manifiesto de dependencias con licencia; sin TTF sin licencia |
| **P1-05** | P1 | Avisos | Actualizar `THIRD_PARTY_NOTICES` con: CachyOS (o su eliminación), Keyitdev/SDDM, Audiowide, set de iconos, wallpapers | Owner | Avisos coinciden con los archivos realmente distribuidos |
| **P1-06** | P1 | Automatización | Test que falle si: hay un blob de CachyOS, falta `LICENSE`, falta una entrada del manifiesto o aparece un logo de Ubuntu | Owner + Empaquetado | Test en CI verde; se ejecuta antes de construir la ISO |
| **P1-07** | P1 | Separación de assets | Sacar los wallpapers personales del paquete de branding; el arte de la distro debe vivir en `distro/branding/` con su licencia | Owner | `Wallpapers/` deja de ser la fuente de la ISO; branding tiene su propio set |
| **P1-08** | P1 | Marca | Búsqueda de anterioridad de "Mytical"; revisar la política de marcas de Canonical antes de publicar | Legal | Informe de marca; aviso de no afiliación aprobado |

---

## 7. Puerta de release (checklist)

No construir la ISO hasta que todo esto sea verdad:

- [ ] **P0-01, P0-02, P0-03, P0-04, P0-05 y P0-06 cerrados.**
- [ ] `LICENSE` raíz y licencia de assets propios presentes y compatibles con
      GPL-3.0-or-later del tema SDDM.
- [ ] `THIRD_PARTY_NOTICES` actualizado y sin afirmaciones pendientes
      ("se debe verificar", "procedencia pendiente").
- [ ] Cada asset de la ISO tiene una entrada en el manifiesto con: ruta,
      licencia SPDX, autor/titular, URL de origen y SHA-256.
- [ ] `ubuntu/sddm/theme/LICENSE` y la fuente correspondiente viajan en la ISO.
- [ ] No queda ningún blob de CachyOS en el tema Plymouth.
- [ ] Los 22 wallpapers actuales no están en la ISO ni en el repo público.
- [ ] Los 5 iconos de wlogout tienen licencia y atribución.
- [ ] No hay logo oficial de Ubuntu/Canonical en SDDM, Plymouth, wallpapers ni
      iconos; el aviso de no afiliación es visible.
- [ ] Test de CI que verifica lo anterior.

---

## 8. Anexo: comandos de verificación

Reproducible en el checkout, sin modificar nada:

```sh
# Copias byte a byte contra CachyOS (throbber) y contra SDDM (tema)
git hash-object ubuntu/plymouth/mytical/throbber-00.png
git hash-object ubuntu/sddm/theme/Main.qml

# Dimensiones y formato real de un asset
ffprobe -v error -show_entries stream=width,height,pix_fmt -of csv=p=0 \
  ubuntu/plymouth/mytical/animation-20.png

# EXIF de la fotografía
ffprobe -v quiet -print_format json -show_format -show_streams Wallpapers/6.jpg

# Listado de assets versionados
git ls-files 'Wallpapers/*' 'wlogout/icons/*' 'ubuntu/plymouth/**' \
  'ubuntu/sddm/theme/**' 'kitty/**'
```

Checksums de los casos de mayor riesgo (para verificar que un reemplazo es
realmente distinto):

```text
58c7f2c738baf1bdeddc67d44877fa86f5c4cbe7b2442eafc732543e70d09f52  Wallpapers/ww.jpg
9264f6cee15094050858079b760d1178ddc9e2d23f60a672cf65e3a0f8db0728  Wallpapers/02.jpg
a87522f7f9a3bf42f2b8ca36f3f24e088beed5a984e8465ab73b0676061b155f  Wallpapers/6.jpg
f803f5938664d367259c7488201813d4ee0c595bd4315b885f918d15a636cd47  Wallpapers/w0.jpg
c7c0f2b0f6fad8c623e31772ce79f94a4edb9321ffce9fce978ea892d20ae730  ubuntu/plymouth/fonts/Audiowide-Regular.ttf
3972dc9744f6499f0f9b2dbf76696f2ae7ad8af9b23dde66d6af86c9dfb36986  ubuntu/sddm/theme/LICENSE
```

---

## 9. Notas de alcance

- No se auditó el código (`palette.py`, `mytical-sddm-sync`, scripts) para
  licencia; solo el arte y los temas. La licencia raíz ausente afecta a todo el
  repositorio y se trata en P0-05.
- No se auditó `graphify-out/`: es salida generada, no forma parte de la ISO.
- No se encontraron otros `.png`, `.jpg`, `.svg`, `.ttf` u `.otf` fuera de las
  rutas listadas.
- No se modificó ningún asset ni tema durante esta auditoría; el único archivo
  creado es este documento.
- Las URLs de upstream se citan como evidencia, no como concesión de licencia.
  La ausencia de `LICENSE` en un repo no se interpreta como permiso.

## Resolución parcial — 2026-11-17

- Los **41 throbbers de Plymouth** fueron reemplazados por una animación de anillo
  generada por el proyecto; ya no son blobs de CachyOS.
- Los **5 iconos de wlogout** fueron reemplazados por dibujos line-art generados
  con ImageMagick por el proyecto.
- Siguen pendientes: wallpapers sin procedencia, licencia raíz y revisión de la
  configuración Plymouth derivada.

## Set de wallpapers propio

- Añadido `distro/branding/wallpapers/mytical-01..04.png`, generado por el
  proyecto y dedicado a CC0-1.0.
- Los 22 wallpapers personales de `Wallpapers/` quedan excluidos de la ISO y
  de los paquetes hasta acreditar autoría/licencia.

## Resolución de licencia raíz — 2026-11-17

El código propio queda bajo GPL-3.0-or-later (`LICENSE`, `COPYRIGHT`). Los
assets de terceros conservan GPL/OFL; los generados son CC0. Queda pendiente la
clave APT de producción, no la licencia.
