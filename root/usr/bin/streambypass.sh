#!/bin/bash

EXEMPT_MARK="99"
EXEMPT_TABLE="wanroute"
STATE_FILE="/tmp/streambypass_state.json"

uci get streambypass.settings.enabled | grep -q '^1$' || exit 0
THRESHOLD=$(uci get streambypass.settings.threshold)
TIMEOUT=$(uci get streambypass.settings.timeout)
SUBNET=$(uci get streambypass.settings.subnet)
declare -A RULES

cleanup_rules() {
    now=$(date +%s)
    for key in "${!RULES[@]}"; do
        age=$(( now - ${RULES[$key]} ))
        if [ $age -ge $TIMEOUT ]; then
            src_ip="${key%%|*}"
            dst_ip="${key##*|}"
            iptables -t mangle -D PREROUTING -s "$src_ip" -d "$dst_ip" -j MARK --set-mark "$EXEMPT_MARK" 2>/dev/null
            ip rule del fwmark "$EXEMPT_MARK" table "$EXEMPT_TABLE" 2>/dev/null
            unset RULES[$key]
        fi
    done
}

while true; do
    cleanup_rules
    declare -A BYTES
    conntrack -L -f ipv4 2>/dev/null \
    | grep "src=" \
    | grep -E "src=$SUBNET" \
    | awk '{for (i=1;i<=NF;i++) if ($i ~ /dst=/) print $(i-1)" "$i}' \
    | sed -E 's/src=|dst=//g' \
    | sort | uniq \
    | while read -r src_ip dst_ip; do
        bytes=$(conntrack -L -f ipv4 | grep "src=$src_ip dst=$dst_ip" | grep bytes= | sed -n 's/.*bytes=\([0-9]*\).*/\1/p' | awk '{sum+=$1} END{print sum}')
        key="$src_ip|$dst_ip"
        BYTES[$key]=$bytes
        [ -z "$bytes" ] && continue
        if [ "$bytes" -gt "$THRESHOLD" ] && [ -z "${RULES[$key]}" ]; then
            iptables -t mangle -A PREROUTING -s "$src_ip" -d "$dst_ip" -j MARK --set-mark "$EXEMPT_MARK"
            ip rule add fwmark "$EXEMPT_MARK" table "$EXEMPT_TABLE"
            RULES[$key]=$(date +%s)
        fi
    done
    # Save state to /tmp for dashboard
    echo "{" > "$STATE_FILE"
    for key in "${!BYTES[@]}"; do
        src="${key%%|*}"
        dst="${key##*|}"
        echo "  \"$src → $dst\": ${BYTES[$key]}," >> "$STATE_FILE"
    done
    sed -i '$ s/,$//' "$STATE_FILE"
    echo "}" >> "$STATE_FILE"
    sleep 10
done