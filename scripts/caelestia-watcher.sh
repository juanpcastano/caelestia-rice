#!/bin/bash
STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"
CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
STATE_DIR="$STATE_HOME/caelestia"
SEQUENCES_FILE="$STATE_DIR/sequences.txt"
TMUX_THEME_FILE="$STATE_DIR/theme/tmux-colors.conf"

mkdir -p "$STATE_DIR/theme"

send_sequences_to_tmux_clients() {
    [ -r "$SEQUENCES_FILE" ] || return

    tmux list-clients -F '#{client_tty}' 2>/dev/null | while IFS= read -r tty; do
        [ -n "$tty" ] && [ -w "$tty" ] || continue
        cat "$SEQUENCES_FILE" >"$tty" 2>/dev/null
    done
}

refresh_opencode_theme() {
    local cli_config="$CONFIG_HOME/opencode/cli.json"
    [ -f "$cli_config" ] && touch "$cli_config"
}

reload_tmux_theme() {
    [ -r "$TMUX_THEME_FILE" ] || return
    tmux source-file -q "$TMUX_THEME_FILE" 2>/dev/null || return
    tmux refresh-client -S 2>/dev/null || true
}

# Caelestia may replace generated files with an atomic rename, which reports
# IN_MOVED_TO rather than IN_CREATE/IN_CLOSE_WRITE.
inotifywait -m -e close_write,create,moved_to "$STATE_DIR" "$STATE_DIR/theme" \
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
    esac
done
