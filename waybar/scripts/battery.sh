#!/usr/bin/env bash
#
# Módulo de batería para waybar, que se esconde solo donde no hay batería.
#
# La misma config corre en un portátil y en un PC de mesa. El módulo `battery`
# de serie no sabe de eso: en el PC soltaba "No batteries." en cada arranque y
# dejaba un widget vacío ocupando sitio en la barra. Un módulo `custom` sí,
# porque waybar oculta por completo el que no imprime nada, así que la
# detección sale gratis y no hay que tocar nada por máquina.
#
# Imprime una línea de JSON, o nada en absoluto.

set -u

# Parametrizado para poder probarlo: apuntándolo a un directorio de mentira se
# comprueba el camino "sí hay batería" en una máquina que no la tiene.
supply_dir="${POWER_SUPPLY_DIR:-/sys/class/power_supply}"

shopt -s nullglob
batteries=("$supply_dir"/BAT*)

# Sin batería no hay módulo. Esta línea es toda la detección.
(( ${#batteries[@]} )) || exit 0

bat="${batteries[0]}"
[[ -r "$bat/capacity" && -r "$bat/status" ]] || exit 0

capacity="$(< "$bat/capacity")"
status="$(< "$bat/status")"

# Cuánto queda. El kernel expone la carga en energía (µWh/µW) o en carga
# (µAh/µA) según el portátil, así que se prueban las dos y se acepta que a
# veces no haya ninguna: con la corriente a cero la división no existe.
remaining=""
for pair in "energy_now:power_now" "charge_now:current_now"; do
    now_file="$bat/${pair%%:*}"
    rate_file="$bat/${pair##*:}"
    [[ -r "$now_file" && -r "$rate_file" ]] || continue

    now="$(< "$now_file")"
    rate="$(< "$rate_file")"
    (( rate > 0 )) || continue

    if [[ "$status" == "Charging" ]]; then
        full_file="$bat/${pair%%_*}_full"
        [[ -r "$full_file" ]] || continue
        now=$(( $(< "$full_file") - now ))
    fi

    minutes=$(( now * 60 / rate ))
    remaining="$(printf '%dh %02dm' $(( minutes / 60 )) $(( minutes % 60 )))"
    break
done

# El enchufe es el mismo glifo que usaba el módulo de serie.
case "$status" in
    Charging)              icon=" "; class="charging" ;;
    Full|"Not charging")   icon=" "; class="full" ;;
    *)
        icon=""
        if   (( capacity <= 5 ));  then class="critical"
        elif (( capacity <= 10 )); then class="warning"
        else                            class="discharging"
        fi ;;
esac

tooltip="$status"
[[ -n "$remaining" ]] && tooltip+=" · quedan $remaining"

# printf en vez de una plantilla suelta: el texto va dentro de JSON y waybar lo
# lee con un parser de verdad, así que las comillas tienen que estar bien.
printf '{"text":"%s%s%%","tooltip":"%s","class":"%s","percentage":%s}\n' \
    "$icon" "$capacity" "$tooltip" "$class" "$capacity"
