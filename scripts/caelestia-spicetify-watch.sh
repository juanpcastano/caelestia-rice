#!/bin/bash

command -v spicetify >/dev/null 2>&1 || exit 0

watcher_pattern='[s]picetify watch -s'
if pgrep -u "$(id -u)" -f "$watcher_pattern" >/dev/null 2>&1; then
    exit 0
fi

LOCK_DIR="${XDG_RUNTIME_DIR:-${XDG_STATE_HOME:-$HOME/.local/state}/caelestia}"
mkdir -p "$LOCK_DIR"
exec 9>"$LOCK_DIR/spicetify-watch.lock"
flock -n 9 || exit 0

# Close the race where two Spotify windows start the hook at once.
if pgrep -u "$(id -u)" -f "$watcher_pattern" >/dev/null 2>&1; then
    exit 0
fi

exec spicetify watch -s
