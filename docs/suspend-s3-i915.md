# Cuelgue al suspender en Hyprland (entrada a S3 con i915)

Informe del diagnóstico y del arreglo aplicado. Fecha: 2026-11-11.

## Resumen

La laptop se quedaba en pantalla negra al pedir suspensión desde Hyprland: el
LED seguía encendido, el ventilador seguía girando y solo se recuperaba
apagando a la fuerza.

Causa: el kernel se colgaba en **la última instrucción de la entrada a S3**
(`acpi_enter_sleep_state`), dentro del firmware del BIOS, cuando el `i915` tenía
activos **PSR** y los **estados DC** (firmware DMC de Kaby Lake) tal como los
deja Hyprland.

Arreglo: apagar esos dos estados de ahorro de pantalla por cmdline del kernel.

```
GRUB_CMDLINE_LINUX_DEFAULT="quiet splash i915.enable_psr=0 i915.enable_dc=0"
```

## Entorno

| Componente | Valor |
|---|---|
| Equipo | Dell Latitude 5590 |
| CPU | Intel Core i5-8350U (Kaby Lake-R) |
| GPU | Intel UHD Graphics 620 (`i915`, Kaby Lake) |
| WiFi | Intel Dual Band Wireless-AC 8265 (`iwlwifi`) |
| BIOS | 1.41.0 (2025-04-09) |
| Kernel | `7.0.0-43-generic` (mismo en todos los boots comparados) |
| systemd | 259 |
| Escritorio | Hyprland 0.56.2 desde Nix (wrapper nixGL), greeter GDM |
| Suspend | `mem_sleep = deep` (S3), `/sys/power/state = freeze mem` |

## Síntoma

- Suspender desde Hyprland (`SUPER+CTRL+S` → `systemctl suspend`, o cerrar la
  tapa) deja la pantalla negra.
- La máquina **no llega a dormir**: LED de encendido encendido y ventilador
  sonando.
- No despierta con teclado ni con la tapa; solo responde a un apagado forzado
  (botón 5 s).
- Reproducible al 100%.

## Qué descartó el hardware y el kernel antes de tocar nada

En un boot con sesión GNOME, el mismo día y con el mismo kernel, el suspend
completó dos ciclos enteros:

```
19:44:27  PM: suspend entry (deep)
19:44:27  Filesystems sync: 0.043 seconds
19:44:35  ACPI: PM: Saving platform NVS memory
19:44:35  Disabling non-boot CPUs ...
19:44:35  PM: suspend exit
```

Eso descarta firmware roto para S3 y descarta el kernel como causa genérica:
el fallo depende del **estado que deja la sesión gráfica**.

## Método: localizar la fase con `pm_test`

El journal normal no sirve para esto: tras un apagado forzado se pierden los
últimos mensajes del kernel (journald no alcanza a sincronizar), así que "el
log termina en `PM: suspend entry`" no significa que se cuelgue exactamente ahí.

`/sys/power/pm_test` permite recorrer el camino de suspensión **por fases** y
despertar solo a los 5 s, sin entrar en S3:

| Valor | Fase que ejecuta |
|---|---|
| `freezer` | congelar procesos |
| `devices` | suspender dispositivos (incluye `i915`) |
| `platform` | preparación de plataforma (ACPI) |
| `core` | todo lo anterior + guardar NVS + apagar CPUs |

### Trampa encontrada (y corregida)

El primer intento puso `pm_test=devices` y lo reseteó justo después de
`systemctl suspend`. No sirve: **`systemctl suspend` regresa en cuanto logind
acepta el trabajo**, no cuando la máquina ya se suspendió. Resultado:

```
08:21:21  pm-test: INICIO pm_test=devices
08:21:22  pm-test: FIN (volvió)          <- aquí regresa systemctl
08:21:23  kernel: PM: suspend entry (deep)  <- el suspend real empieza DESPUÉS
```

El `pm_test` se reseteó a `none` un segundo antes del suspend real, así que el
test no midió nada. Lo correcto es dejar el valor puesto y resetearlo **después
del retorno**, no en el mismo instante.

### Resultado con `pm_test=devices` (bien ejecutado)

```
08:30:07  PM: suspend entry (deep)
08:30:07  Filesystems sync: 0.021 seconds
08:30:13  PM: suspend of devices complete after 300.645 msecs
08:30:13  PM: suspend debug: Waiting for 5 second(s).
08:30:13  PM: resume of devices complete after 361.200 msecs
08:30:13  PM: suspend exit
```

Suspender y retomar **todos los dispositivos** funciona, `i915` incluido. Se
descartan drivers y el propio compositor en esa fase.

### Resultado con `pm_test=core`

```
08:41:35  PM: suspend entry (deep)
08:41:35  Filesystems sync: 0.023 seconds
08:41:41  ACPI: PM: Preparing to enter system sleep state S3
08:41:41  ACPI: PM: Saving platform NVS memory
08:41:41  Disabling non-boot CPUs ...
08:41:41  PM: suspend debug: Waiting for 5 second(s).   <- aquí se detiene el test
08:41:41  PM: suspend exit
```

Pasan **todas** las fases previas: preparación ACPI, guardado de NVS y apagado
de las CPUs secundarias. Lo único que queda fuera del test es la instrucción
final que escribe en el registro de suspensión del firmware.

## Causa raíz

El cuelgue ocurre en `acpi_enter_sleep_state(ACPI_STATE_S3)`: el CPU queda
atrapado dentro del SMI del BIOS y nunca se alcanza el estado S3 de bajo
consumo. Por eso el LED sigue encendido y el ventilador sigue girando: no es
que "no despierte", es que **nunca llegó a dormir**.

El disparador es el estado de la pantalla al entrar en S3. Con Hyprland
(aquamarine) el `i915` deja activos **PSR** (Panel Self Refresh) y los estados
**DC** gestionados por el firmware **DMC**, y esa combinación cuelga el
firmware de Kaby Lake en la entrada a S3. GNOME/mutter no deja ese estado, y
por eso suspendía sin problema con el mismo kernel.

## Arreglo aplicado

Se añadieron dos parámetros al cmdline del kernel:

```sh
sudo cp /etc/default/grub /etc/default/grub.bak-20261111-084633
sudo sed -i 's/^GRUB_CMDLINE_LINUX_DEFAULT="\(.*\)"/GRUB_CMDLINE_LINUX_DEFAULT="\1 i915.enable_psr=0 i915.enable_dc=0"/' /etc/default/grub
sudo update-grub
```

Resultado:

```
GRUB_CMDLINE_LINUX_DEFAULT="quiet splash i915.enable_psr=0 i915.enable_dc=0"
```

Verificado en las dos entradas de `/boot/grub/grub.cfg` (normal y recovery), y
en `/proc/cmdline` tras el reinicio.

Se mantiene **S3 real**: no se cambió a `s2idle`, así que el ahorro de batería
del suspend se conserva. El coste es un poco más de consumo de pantalla en
reposo, una vez apagados PSR y los estados DC.

## Verificación

Dos ciclos completos de S3 después del reinicio, con la máquina dormida 12 s:

```
08:48:49  PM: suspend entry (deep)
08:48:49  Filesystems sync: 0.010 seconds
08:49:01  ACPI: PM: Preparing to enter system sleep state S3
08:49:01  ACPI: PM: Saving platform NVS memory
08:49:01  Disabling non-boot CPUs ...
08:49:01  PM: suspend exit
08:49:31  PM: suspend entry (deep)
08:49:43  PM: suspend exit
```

## Reversión

```sh
sudo cp /etc/default/grub.bak-20261111-084633 /etc/default/grub
sudo update-grub
```

## Plan B (si vuelve a aparecer)

Si un cambio de kernel o de BIOS reintroduce el fallo, la alternativa es
esquivar la entrada S3 del firmware por completo:

```
mem_sleep_default=s2idle
```

Funciona en este hardware, pero en Kaby Lake s2idle gasta más batería en
reposo que S3 real.

## Hipótesis descartadas

| Hipótesis | Cómo se descartó |
|---|---|
| Inhibidor bloqueando el suspend | `systemd-inhibit --list`: solo inhibidores `delay` (NetworkManager, UPower, brave…), ninguno `block` |
| `sync` de filesystems colgado | `sync` de usuario termina OK; `Filesystems sync: 0.021 s` en el test |
| Filesystem de red / FUSE colgado | sin NFS/CIFS/sshfs; solo `portal` y `gvfsd-fuse` normales |
| Disco / errores de I/O | `smartctl`: PASSED; sin errores en dmesg |
| Kernel roto para S3 | GNOME suspendió 2 veces completo con el mismo `7.0.0-43-generic` |
| Drivers / compositor en fase de dispositivos | `pm_test=devices` completa en 300 ms y retoma bien |
| PSR o DC como culpables de la fase previa | toda la fase previa (NVS y CPUs) pasa con `pm_test=core`; el cuelgue es solo la entrada en firmware |

## Instrumentación usada (y retirada)

Para no perder el rastro tras cada apagado forzado se usó, temporalmente:

- `SyncIntervalSec=1s` en journald (drop-in en
  `/etc/systemd/journald.conf.d/99-debug-sync.conf`) — **eliminado** al
  terminar; vuelve al default de 5 min.
- `pm_debug_messages=1`, `initcall_debug=1`, `console_suspend=0` — se
  resetean solos al reiniciar; verificados en sus valores normales al cerrar.

## Comandos de referencia

```sh
# estado de energía y capacidades
cat /sys/power/state /sys/power/mem_sleep

# quién inhibe el suspend
systemd-inhibit --list

# ciclos de suspend en el boot actual / anterior
journalctl -k -b 0  | grep -E 'PM: suspend|ACPI: PM|Disabling non-boot'
journalctl -k -b -1 | grep -E 'PM: suspend|ACPI: PM|Disabling non-boot'

# test por fases (dejar pm_test puesto; resetear DESPUÉS del retorno)
echo devices > /sys/power/pm_test
systemctl suspend
# ... tras volver:
echo none > /sys/power/pm_test

# sospechosos de S3 con i915 en Kaby Lake
#   i915.enable_psr=0
#   i915.enable_dc=0
#   mem_sleep_default=s2idle
```

## Para recordar

1. `systemctl suspend` regresa cuando logind acepta el trabajo, no cuando la
   máquina ya durmió. Cualquier test por fases tiene que respetar eso.
2. Tras un apagado forzado el journal pierde los últimos mensajes: "el log
   termina en X" no es prueba de que el cuelgue sea en X.
3. Que GNOME funcione y Hyprland no, con el mismo kernel, apunta al estado
   que deja la sesión gráfica (GPU/pantalla), no al hardware.
