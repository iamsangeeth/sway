#!/usr/bin/env sh
# Toggle the default output between the Pebble V3 speakers and USB docking stereo.

set -eu

speakers='alsa_output.usb-ACTIONS_Pebble_V3-00.analog-stereo'
docking='alsa_output.usb-DisplayLink_USB3.0_5K_Graphic_Docking_4310338944098-02.analog-stereo'

if ! command -v pactl >/dev/null 2>&1; then
    printf '%s\n' 'audio-output-switch: pactl is required' >&2
    exit 1
fi

sink_exists() {
    pactl list short sinks | awk -v wanted="$1" '$2 == wanted { found = 1 } END { exit !found }'
}

for sink in "$speakers" "$docking"; do
    if ! sink_exists "$sink"; then
        printf 'audio-output-switch: sink is not available: %s\n' "$sink" >&2
        exit 1
    fi
done

current=$(pactl get-default-sink)
if [ "$current" = "$speakers" ]; then
    target=$docking
    label='USB docking stereo'
else
    target=$speakers
    label='Pebble V3'
fi

if [ "${1-}" = '--check' ]; then
    printf 'current=%s\ntarget=%s\n' "$current" "$target"
    exit 0
fi

pactl set-default-sink "$target"
# Move existing applications too; changing the default alone only affects new streams.
while read -r input_id; do
    [ -n "$input_id" ] || continue
    pactl move-sink-input "$input_id" "$target" 2>/dev/null || true
done <<EOF
$(pactl list short sink-inputs | awk '{print $1}')
EOF

if command -v notify-send >/dev/null 2>&1; then
    notify-send -u low -t 1800 'Audio output' "$label" 2>/dev/null || true
fi
printf '%s\n' "$target"
