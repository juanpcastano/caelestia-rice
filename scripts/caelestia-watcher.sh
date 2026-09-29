#!/bin/bash
STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"
STATE_DIR="$STATE_HOME/caelestia"
SEQUENCES_FILE="$STATE_DIR/sequences.txt"
TMUX_THEME_FILE="$STATE_DIR/theme/tmux-colors.conf"
PIXIE_SYNC="$HOME/.local/bin/caelestia-pixie-sync"

mkdir -p "$STATE_DIR/theme" "$STATE_DIR/wallpaper"

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
            [ -x "$PIXIE_SYNC" ] && "$PIXIE_SYNC" || true
            ;;
    esac
done
