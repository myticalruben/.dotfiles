#!/usr/bin/env bash
# One bar for every machine: a laptop has a battery and gets the Wi-Fi glyph;
# a desktop or a VM has no battery and gets the IPv4 of its default route.
set -u

for bat in /sys/class/power_supply/BAT*; do
    if [ -d "$bat" ]; then
        printf '{"text":"","class":"wifi"}\n'
        exit 0
    fi
done

iface=$(ip route get 1.1.1.1 2>/dev/null \
    | awk '{ for (i = 1; i <= NF; i++) if ($i == "dev") { print $(i + 1); exit } }')
if [ -z "$iface" ]; then
    iface=$(ip -4 route show default 2>/dev/null | awk '{ print $5; exit }')
fi

ip=""
if [ -n "$iface" ]; then
    ip=$(ip -4 -o addr show dev "$iface" scope global 2>/dev/null \
        | awk '{ print $4; exit }' | cut -d/ -f1)
fi
[ -n "$ip" ] || ip=$(hostname -I 2>/dev/null | awk '{ print $1 }')

printf '{"text":"%s","class":"ip"}\n' "${ip:-no-ip}"
