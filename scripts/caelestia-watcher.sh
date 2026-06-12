#!/bin/bash
STATE_DIR="$HOME/.local/state/caelestia"

send_reset_to_tmux_panes() {
    tmux list-panes -a -F '#{pane_tty}' 2>/dev/null | while read -r tty; do
        # 1. Resetear Fondo, Primer plano, Cursor y Selección a los defaults del emulador
        printf '\033]110\033\\' >"$tty" 2>/dev/null # Cursor
        printf '\033]111\033\\' >"$tty" 2>/dev/null # Fondo (Aquí está la magia de la transparencia)
        printf '\033]112\033\\' >"$tty" 2>/dev/null # Texto
        printf '\033]117\033\\' >"$tty" 2>/dev/null # Highlight/Selección

        # 2. LA CLAVE: Resetear TODA la paleta de colores ANSI a los defaults del emulador
        printf '\033]104\033\\' >"$tty" 2>/dev/null
    done
}

inotifywait -m -e close_write,create "$STATE_DIR" "$STATE_DIR/theme" --format '%w%f' 2>/dev/null | while read -r filepath; do
    file=$(basename "$filepath")
    if [ "$file" = "sequences.txt" ]; then
        send_reset_to_tmux_panes
    elif [ "$file" = "tmux-colors.conf" ]; then
        tmux source-file "$HOME/.config/tmux/tmux.conf" 2>/dev/null
    fi
done
