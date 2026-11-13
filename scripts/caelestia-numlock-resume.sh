#!/usr/bin/env bash

# Hyprland can keep the NumLock modifier visually enabled while losing the
# keypad translation after suspend. Toggling the modifier twice after resume
# makes the LED, xkb state and keypad translation agree again.

set -u

log() {
    printf '%s %s\n' "$(date '+%F %T')" "$*"
}

resync_numlock() {
    # ydotoold can take a moment to recreate /dev/uinput after a
    # hibernate resume. Retry instead of silently losing the fix.
    for _ in {1..10}; do
        if ydotool key 69:1 69:0 69:1 69:0 >/dev/null 2>&1; then
            log "NumLock resynchronised"
            return
        fi
        sleep 1
    done
    log "NumLock resync failed: ydotool did not respond"
}

# gdbus monitor exits when the system bus connection drops. Reconnect instead
# of letting the service stop silently with exit code 0.
while true; do
    log "watching logind PrepareForSleep"
    gdbus monitor \
        --system \
        --dest org.freedesktop.login1 \
        --object-path /org/freedesktop/login1 |
    while IFS= read -r event; do
        case "$event" in
            *"PrepareForSleep"*"(false,"*)
                log "resume detected"
                # Let the compositor and the lock surface finish restoring first.
                sleep 1
                resync_numlock
                ;;
        esac
    done
    log "logind monitor stopped, reconnecting in 2s"
    sleep 2
done
