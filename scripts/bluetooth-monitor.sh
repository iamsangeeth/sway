#!/usr/bin/env bash
# Monitor Bluetooth device disconnections and log for debugging
# Can be used to correlate with Waybar crashes

LOG_FILE="/tmp/bluetooth-monitor.log"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

# Monitor Bluetooth events using bluetoothctl
bluetoothctl monitor | while read -r line; do
    case "$line" in
        *"[CHG]"*"Connected: no"*)
            log "Device disconnected: $line"
            # Check if Waybar is still running
            if ! pgrep -x waybar > /dev/null; then
                log "WARNING: Waybar not running after device disconnection!"
            fi
            ;;
        *"[CHG]"*"Connected: yes"*)
            log "Device connected: $line"
            ;;
    esac
done
