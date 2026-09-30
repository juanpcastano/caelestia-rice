#!/bin/bash
STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"
STATE_DIR="$STATE_HOME/caelestia"
SEQUENCES_FILE="$STATE_DIR/sequences.txt"
TMUX_THEME_FILE="$STATE_DIR/theme/tmux-colors.conf"
GREETER_WALLPAPER_DIR="/var/cache/caelestia-greeter/state/wallpaper"
GREETER_SCHEME_FILE="/var/cache/caelestia-greeter/state/scheme.json"

mkdir -p "$STATE_DIR/theme" "$STATE_DIR/wallpaper"
exec 9>"$STATE_DIR/watcher.lock"
flock -n 9 || exit 0

send_sequences_to_tmux_clients() {
    [ -r "$SEQUENCES_FILE" ] || return

    tmux list-clients -F '#{client_tty}' 2>/dev/null | while IFS= read -r tty; do
        [ -n "$tty" ] && [ -w "$tty" ] || continue
        cat "$SEQUENCES_FILE" >"$tty" 2>/dev/null
    done
}

refresh_opencode_theme() {
    # OpenCode 2.x refreshes its terminal-derived system theme on SIGUSR2.
    ps -u "$(id -u)" -o pid=,tty=,comm= | while read -r pid tty comm; do
        [ "$tty" != "?" ] && [ "$comm" = "opencode" ] || continue
        [ -r "/proc/$pid/cmdline" ] || continue

        local command extra
        read -r command extra < <(tr '\0' '\n' <"/proc/$pid/cmdline")
        [ "$command" = "opencode" ] && [ -z "$extra" ] || continue
        kill -USR2 "$pid" 2>/dev/null || true
    done
}

reload_tmux_theme() {
    [ -r "$TMUX_THEME_FILE" ] || return
    tmux source-file -q "$TMUX_THEME_FILE" 2>/dev/null || return
    tmux refresh-client -S 2>/dev/null || true
}

sync_greeter_wallpaper() {
    local source extension target
    [ -r "$STATE_DIR/wallpaper/path.txt" ] || return
    source="$(head -n 1 "$STATE_DIR/wallpaper/path.txt" | tr -d '\r')"
    [ -f "$source" ] || return

    extension="${source##*.}"
    case "${extension,,}" in
        png|jpg|jpeg|webp|bmp|gif|svg|avif) extension="${extension,,}" ;;
        *) extension="img" ;;
    esac
    target="$GREETER_WALLPAPER_DIR/live.$extension"
    [ -d "$GREETER_WALLPAPER_DIR" ] || return
    rm -f "$GREETER_WALLPAPER_DIR/live" "$GREETER_WALLPAPER_DIR"/live.*
    cp -- "$source" "$target.tmp" 2>/dev/null || return
    chmod 0644 "$target.tmp"
    mv -f -- "$target.tmp" "$target"
    printf '%s\n' "$target" >"$GREETER_WALLPAPER_DIR/path.txt.tmp"
    chmod 0644 "$GREETER_WALLPAPER_DIR/path.txt.tmp"
    mv -f -- "$GREETER_WALLPAPER_DIR/path.txt.tmp" "$GREETER_WALLPAPER_DIR/path.txt"
}

sync_greeter_scheme() {
    local source scheme
    [ -r "$STATE_DIR/wallpaper/path.txt" ] || return
    source="$(head -n 1 "$STATE_DIR/wallpaper/path.txt" | tr -d '\r')"
    [ -f "$source" ] || return

    # Generate the greeter palette from the wallpaper itself. This avoids a
    # race with Caelestia's normal scheme writer when the wallpaper changes.
    scheme="$(caelestia wallpaper --print "$source" 2>/dev/null)" || scheme=""
    [ -n "$scheme" ] || return
    printf '%s\n' "$scheme" >"$GREETER_SCHEME_FILE.tmp" 2>/dev/null || return
    chmod 0644 "$GREETER_SCHEME_FILE.tmp"
    mv -f -- "$GREETER_SCHEME_FILE.tmp" "$GREETER_SCHEME_FILE"
}

sync_greeter_wallpaper
sync_greeter_scheme

# Caelestia may replace generated files with an atomic rename, which reports
# IN_MOVED_TO rather than IN_CREATE/IN_CLOSE_WRITE.
inotifywait -m -e close_write,create,moved_to "$STATE_DIR" "$STATE_DIR/theme" "$STATE_DIR/wallpaper" \
    --format '%w%f' 2>/dev/null | while IFS= read -r filepath; do
    case "$filepath" in
        "$SEQUENCES_FILE")
            send_sequences_to_tmux_clients
            # OpenCode watches cli.json for live settings changes. Touch it after
            # Caelestia has sent the new terminal palette so `theme: system`
            # can resolve the updated colors without restarting the TUI.
            refresh_opencode_theme
            ;;
        "$TMUX_THEME_FILE") reload_tmux_theme ;;
        "$STATE_DIR/wallpaper/path.txt")
            sync_greeter_wallpaper
            sync_greeter_scheme
            ;;
        "$STATE_DIR/scheme.json") sync_greeter_scheme ;;
    esac
done
