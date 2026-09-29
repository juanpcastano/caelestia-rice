#!/bin/sh

# Keep the Pixie SDDM greeter in sync with Caelestia's generated wallpaper.
# Pixie extracts its own Material colors from this wallpaper.

set -eu

state_home=${XDG_STATE_HOME:-"$HOME/.local/state"}
state_dir="$state_home/caelestia"
wallpaper_file="$state_dir/wallpaper/path.txt"
target_dir=/var/cache/pixie-sddm
target_conf="$target_dir/theme.conf"

[ -r "$wallpaper_file" ] || exit 0

wallpaper=$(sed -n '1p' "$wallpaper_file")
[ -f "$wallpaper" ] || exit 0

python3 - "$wallpaper" "$target_dir" "$target_conf" <<'PY'
import os
import shutil
import sys
import tempfile

wallpaper, target_dir, target_conf = sys.argv[1:]

os.makedirs(target_dir, mode=0o755, exist_ok=True)

fd, temporary = tempfile.mkstemp(prefix="background.", dir=target_dir)
os.close(fd)
try:
    shutil.copyfile(wallpaper, temporary)
    os.chmod(temporary, 0o644)
    os.replace(temporary, os.path.join(target_dir, "background"))
finally:
    if os.path.exists(temporary):
        os.unlink(temporary)

fd, temporary = tempfile.mkstemp(prefix="theme.", dir=target_dir, text=True)
with os.fdopen(fd, "w", encoding="utf-8") as stream:
    stream.write("[General]\n")
    stream.write("background=/var/cache/pixie-sddm/background\n")
    stream.write("autoColor=true\n")
    stream.write("use24HourClock=true\n")
    stream.write("fontFamily=\n")
os.chmod(temporary, 0o644)
os.replace(temporary, target_conf)
PY

# /usr/share/sddm/themes/pixie/theme.conf is installed as a symlink to the
# cache file by the manifest. This script deliberately needs no sudo so it can
# run from a user systemd path unit whenever Caelestia changes its theme.
