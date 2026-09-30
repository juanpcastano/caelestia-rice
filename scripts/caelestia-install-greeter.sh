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

# Keep a shared, user-writable wallpaper cache that the greeter can watch.
sync_path = Path("/usr/local/bin/caelestia-greeter-profile-sync")
sync_text = sync_path.read_text(encoding="utf-8")
old_wallpaper_env = (
    '    if [[ -n "$wallpaper_cache" ]]; then\n'
    + '        printf \'CAELESTIA_GREETER_WALLPAPER=%q\\n\' "$wallpaper_cache"\n'
    + '    fi\n'
)
if old_wallpaper_env in sync_text:
    sync_text = sync_text.replace(old_wallpaper_env, "", 1)
wallpaper_target = 'copy_asset "$wallpaper_source" "$cache_dir/wallpaper"'
if wallpaper_target in sync_text:
    sync_text = sync_text.replace(
        wallpaper_target,
        'copy_asset "$wallpaper_source" "$state_cache/wallpaper/live"',
        1,
    )
else:
    raise SystemExit("Unable to patch the greeter wallpaper cache path")
scheme_copy = (
    '    install -m 0644 "$scheme_source" "$scheme_cache.tmp"\n'
    + '    mv -f "$scheme_cache.tmp" "$scheme_cache"\n'
)
scheme_copy_live = scheme_copy + '    chmod 0644 "$scheme_cache"\n'
if scheme_copy_live not in sync_text:
    if scheme_copy not in sync_text:
        raise SystemExit("Unable to make the greeter scheme readable")
    sync_text = sync_text.replace(scheme_copy, scheme_copy_live, 1)
owner_marker = 'passwd_entry="$(getent passwd "$user" || true)"\n'
owner_code = 'chown "$user:$service_group" "$state_cache" "$state_cache/wallpaper"\n\n'
if owner_code not in sync_text:
    sync_text = sync_text.replace(owner_marker, owner_code + owner_marker, 1)
fd, temporary = tempfile.mkstemp(prefix="caelestia-greeter-profile-sync.", dir=str(sync_path.parent), text=True)
with os.fdopen(fd, "w", encoding="utf-8") as stream:
    stream.write(sync_text)
os.chmod(temporary, 0o755)
os.replace(temporary, sync_path)

config_path = Path("/etc/xdg/quickshell/caelestia-greeter/config/Config.qml")
config_text = config_path.read_text(encoding="utf-8")
config_watch = "        watchChanges: true\n        printErrors: false\n"
if "onFileChanged: reload()" not in config_text:
    if config_watch not in config_text:
        raise SystemExit("Unable to enable live wallpaper reload")
    config_text = config_text.replace(
        config_watch,
        "        watchChanges: true\n        onFileChanged: reload()\n        printErrors: false\n",
        1,
    )
fd, temporary = tempfile.mkstemp(prefix="caelestia-greeter-config.", dir=str(config_path.parent), text=True)
with os.fdopen(fd, "w", encoding="utf-8") as stream:
    stream.write(config_text)
os.chmod(temporary, 0o644)
os.replace(temporary, config_path)

theme_path = Path("/etc/xdg/quickshell/caelestia-greeter/design/Theme.qml")
theme_text = theme_path.read_text(encoding="utf-8")
revision_marker = "    FileView {\n        id: schemeFile\n"
if "property int schemeRevision" not in theme_text:
    if revision_marker not in theme_text:
        raise SystemExit("Unable to add the greeter scheme revision")
    theme_text = theme_text.replace(
        revision_marker,
        "    property int schemeRevision: 0\n\n" + revision_marker,
        1,
    )
scheme_watch = (
    "        path: Config.schemePath\n"
    + "        blockLoading: true\n"
    + "        watchChanges: true\n"
    + "        printErrors: false\n"
)
scheme_watch_simple = scheme_watch.replace(
    "        watchChanges: true\n",
    "        watchChanges: true\n        onFileChanged: reload()\n",
)
scheme_watch_live = scheme_watch.replace(
    "        watchChanges: true\n",
    "        watchChanges: true\n"
    + "        onFileChanged: {\n"
    + "            reload()\n"
    + "            root.schemeRevision += 1\n"
    + "        }\n",
)
if scheme_watch in theme_text:
    theme_text = theme_text.replace(scheme_watch, scheme_watch_live, 1)
elif scheme_watch_simple in theme_text:
    theme_text = theme_text.replace(scheme_watch_simple, scheme_watch_live, 1)
elif scheme_watch_live not in theme_text:
    raise SystemExit("Unable to enable live scheme reload")
scheme_text_marker = "    readonly property var schemeData: {\n"
if "readonly property string schemeText" not in theme_text:
    if scheme_text_marker not in theme_text:
        raise SystemExit("Unable to make the greeter scheme reactive")
    theme_text = theme_text.replace(
        scheme_text_marker,
        "    readonly property string schemeText: {\n"
        + "        root.schemeRevision;\n"
        + "        return schemeFile.text();\n"
        + "    }\n\n"
        + scheme_text_marker,
        1,
    )
theme_text = theme_text.replace(
    "const contents = schemeFile.text();",
    "const contents = root.schemeText;",
    1,
)
fd, temporary = tempfile.mkstemp(prefix="caelestia-greeter-theme.", dir=str(theme_path.parent), text=True)
with os.fdopen(fd, "w", encoding="utf-8") as stream:
    stream.write(theme_text)
os.chmod(temporary, 0o644)
os.replace(temporary, theme_path)
PY

# Regenerate the profile and shared wallpaper cache immediately.
sudo /usr/local/bin/caelestia-greeter-profile-sync
