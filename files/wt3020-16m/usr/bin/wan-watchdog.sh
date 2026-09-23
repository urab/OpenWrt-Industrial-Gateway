#!/bin/sh

FAILS=0
STATE="wan"

while true; do
    GW="$(ifstatus wan 2>/dev/null | jsonfilter -e '@.route[0].nexthop')"
    [ -n "$GW" ] && ip route replace 8.8.8.8/32 via "$GW" dev eth0.2 2>/dev/null

    if ping -I eth0.2 -c 1 -W 2 8.8.8.8 >/dev/null 2>&1; then
        FAILS=0
        if [ "$STATE" != "wan" ] && [ -n "$GW" ]; then
            ip route replace default via "$GW" dev eth0.2
            logger -t wan-watchdog "WAN restored, switched back to eth0.2"
            STATE="wan"
        fi
    else
        FAILS=$((FAILS + 1))
        if [ "$FAILS" -ge 3 ] && [ "$STATE" != "modem" ]; then
            ip route del default dev eth0.2 2>/dev/null
            logger -t wan-watchdog "WAN failed, switched to USB modem"
            STATE="modem"
        fi
    fi
    sleep 5
done
