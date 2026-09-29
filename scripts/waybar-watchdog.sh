#!/usr/bin/env bash
# Watches for system resume (suspend/resume cycle) and restarts waybar
# if it died, since NVIDIA + Wayland suspend/resume can silently kill
# waybar's GPU-rendered surface without sway or the compositor crashing.
# Also restarts on Bluetooth audio device disconnection crashes.

LOG_FILE="/tmp/waybar-watchdog.log"
PID_FILE="${XDG_RUNTIME_DIR:-/tmp}/waybar-watchdog.pid"
# Single instance: exit if a live watchdog already holds the pidfile
if [ -f "$PID_FILE" ] && kill -0 "$(cat "$PID_FILE" 2>/dev/null)" 2>/dev/null; then
    exit 0
fi
echo $$ > "$PID_FILE"

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
        # Recheck after a delay: at boot/reload, $waybar_start
        # (killall; sleep 0.1; waybar) may still be starting waybar.
        sleep 2
        if ! pgrep -x waybar > /dev/null; then
            restart_waybar
        fi
    fi
    sleep 5
done
