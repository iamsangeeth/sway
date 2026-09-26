#!/bin/sh
# Allow suspend only if no SSH (pts) sessions are active, so the machine
# stays awake while it is being used over SSH. Used by swayidle's sleep
# timeout in config.d/definitions.conf.
# exit 0 = suspend allowed, exit 1 = suspend blocked
loginctl list-sessions --no-legend 2>/dev/null |
    awk '$6 == "user" && $7 ~ /^pts\//' |
    grep -q . && exit 1
exit 0
