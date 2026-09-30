#!/bin/sh

# Install the upstream Caelestia Greeter and apply rice-owned input defaults.

set -eu

source_dir="${XDG_CACHE_HOME:-$HOME/.cache}/caelestia-rice/caelestia-greeter"
repository="https://github.com/maylton/caelestia-greeter.git"

mkdir -p "$(dirname "$source_dir")"

if [ -d "$source_dir/.git" ]; then
    git -C "$source_dir" pull --ff-only
else
    rm -rf "$source_dir"
    git clone --depth 1 "$repository" "$source_dir"
fi

bash "$source_dir/install.sh" --yes --no-keyring --user "$(id -un)"

# The upstream compositor generates this Lua file at login time. Patch its
# generated input block after every install/update so the settings persist.
sudo python3 - <<'PY'
from pathlib import Path
import os
import tempfile

path = Path("/usr/local/bin/caelestia-greeter-compositor")
text = path.read_text(encoding="utf-8")
needle = '        kb_layout = "br",\n'
settings = (
    '        kb_layout = "us",\n'
    + '        kb_variant = "intl",\n'
    + '        kb_model = "",\n'
    + '        kb_options = "caps:escape",\n'
    + '        kb_rules = "",\n'
    + "        numlock_by_default = true,\n"
    + "        repeat_delay = 250,\n"
    + "        repeat_rate = 35,\n"
    + "        follow_mouse = 1,\n"
    + '        sensitivity = 0.0,\n'
    + '        accel_profile = "flat",\n'
    + '        natural_scroll = false,\n'
)

if needle in text:
    text = text.replace(needle, settings, 1)
elif "numlock_by_default" in text:
    # Keep an already-patched installation aligned with the rice too.
    text = text.replace('accel_profile = "adaptive"', 'accel_profile = "flat"')
else:
    raise SystemExit("Unable to find the greeter input block to patch")

cursor_env = (
    'hl.env("XCURSOR_THEME", "Graphite-dark-nord-cursors")\n'
    + 'hl.env("XCURSOR_SIZE", 16)\n'
)
if 'XCURSOR_THEME", "Graphite-dark-nord-cursors' not in text:
    marker = 'hl.config({\n'
    if marker not in text:
        raise SystemExit("Unable to find the greeter Hyprland config block")
    text = text.replace(marker, cursor_env + marker, 1)

fd, temporary = tempfile.mkstemp(prefix="caelestia-greeter-compositor.", dir=str(path.parent), text=True)
with os.fdopen(fd, "w", encoding="utf-8") as stream:
    stream.write(text)
os.chmod(temporary, 0o755)
os.replace(temporary, path)

run_path = Path("/usr/local/bin/caelestia-greeter-run")
run_text = run_path.read_text(encoding="utf-8")
old_dispatch = "/usr/bin/hyprctl dispatch exit"
new_dispatch = "/usr/bin/hyprctl dispatch 'hl.dsp.exit()'"
if old_dispatch in run_text:
    run_text = run_text.replace(old_dispatch, new_dispatch, 1)
elif new_dispatch not in run_text:
    raise SystemExit("Unable to find the greeter Hyprland exit dispatcher")
fd, temporary = tempfile.mkstemp(prefix="caelestia-greeter-run.", dir=str(run_path.parent), text=True)
with os.fdopen(fd, "w", encoding="utf-8") as stream:
    stream.write(run_text)
os.chmod(temporary, 0o755)
os.replace(temporary, run_path)
PY
