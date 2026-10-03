#!/bin/sh
# Allow suspend only if no SSH (pts) sessions are active, so the machine
# stays awake while it is being used over SSH. Also blocks suspend while the
# GPU is not idle, so long GPU jobs (e.g. llama-server) are not interrupted.
# Used by swayidle's sleep timeout in config.d/definitions.conf.
# exit 0 = suspend allowed, exit 1 = suspend blocked
loginctl list-sessions --no-legend 2>/dev/null |
    awk '$6 == "user" && $7 ~ /^pts\//' |
    grep -q . && exit 1

# Block suspend while the GPU is busy (utilization above threshold).
GPU_IDLE_THRESHOLD=20
if command -v nvidia-smi >/dev/null 2>&1; then
    util=$(nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits 2>/dev/null \
        | awk '{if ($1+0 > max) max=$1+0} END{print max+0}')
    [ "${util:-0}" -gt "$GPU_IDLE_THRESHOLD" ] && exit 1
fi
exit 0
