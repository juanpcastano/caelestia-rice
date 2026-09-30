#!/usr/bin/env bash

# Hyprland can keep the NumLock modifier visually enabled while losing the
# keypad translation after suspend. Toggling the modifier twice after resume
# makes the LED, xkb state and keypad translation agree again.

set -u

gdbus monitor \
    --system \
    --dest org.freedesktop.login1 \
    --object-path /org/freedesktop/login1 |
while IFS= read -r event; do
    case "$event" in
        *"PrepareForSleep"*"(false,"*)
            # Let the compositor and the lock surface finish restoring first.
            sleep 1
            ydotool key 69:1 69:0 69:1 69:0 >/dev/null 2>&1 || true
            ;;
    esac
done
