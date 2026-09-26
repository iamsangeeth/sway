#!/usr/bin/env bash
# Watches for system resume (suspend/resume cycle) and restarts waybar
# if it died, since NVIDIA + Wayland suspend/resume can silently kill
# waybar's GPU-rendered surface without sway or the compositor crashing.
# Also restarts on Bluetooth audio device disconnection crashes.

LOG_FILE="/tmp/waybar-watchdog.log"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

restart_waybar() {
    log "Waybar not running, restarting..."
    # Kill any existing waybar processes
    pkill -x waybar 2>/dev/null
    sleep 0.5
    # Start waybar
    waybar 2>&1 | while read -r line; do
        log "Waybar: $line"
    done &
    log "Waybar restarted with PID $!"
}

while true; do
    if ! pgrep -x waybar > /dev/null; then
        restart_waybar
    fi
    sleep 5
done
