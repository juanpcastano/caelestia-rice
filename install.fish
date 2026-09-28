#!/usr/bin/env fish

# Bootstrap the official Caelestia CLI, configure it to use this dots repo,
# then let `caelestia install` process this repository's manifest.toml.

if test (id -u) -eq 0
    echo "Do not run this script as root; it invokes sudo when required."
    exit 1
end

if not test -f /etc/os-release
    echo "Cannot identify this distribution (/etc/os-release is missing)."
    exit 1
end

source /etc/os-release
if not string match -q '*arch*' "$ID $ID_LIKE"
    echo "The Caelestia CLI package installer targets Arch-based distributions."
    echo "Detected: $PRETTY_NAME"
    exit 1
end

set script_dir (dirname (realpath (status filename)))
set repo_url (git -C $script_dir remote get-url origin 2>/dev/null)
set branch (git -C $script_dir branch --show-current 2>/dev/null)

if test -z "$repo_url"; or test -z "$branch"
    echo "Run this from a checked-out git clone with an origin remote and a branch."
    exit 1
end

# Public GitHub repos should remain cloneable on a fresh machine without an SSH key.
set repo_url (string replace 'git@github.com:' 'https://github.com/' -- $repo_url)

# Reuse paru/yay when available, otherwise bootstrap paru from the AUR.
set aur_helper paru
if not command -v paru >/dev/null; and command -v yay >/dev/null
    set aur_helper yay
end

if not command -v $aur_helper >/dev/null
    echo "Installing paru (AUR helper)..."
    sudo pacman -S --needed git base-devel
    set build_dir (mktemp -d)
    or exit 1
    git clone https://aur.archlinux.org/paru.git $build_dir/paru
    or begin
        rm -rf $build_dir
        exit 1
    end
    cd $build_dir/paru
    makepkg -si
    set result $status
    cd $script_dir
    rm -rf $build_dir
    if test $result -ne 0
        exit $result
    end
    set aur_helper paru
end

if not command -v caelestia >/dev/null
    $aur_helper -S --needed caelestia-cli
    or exit $status
end

# Tell the CLI to clone/update this repository instead of caelestia-dots/caelestia.
set config_home $XDG_CONFIG_HOME
if test -z "$config_home"
    set config_home $HOME/.config
end
set cli_config $config_home/caelestia/cli.json
mkdir -p (dirname $cli_config)
or exit 1

python3 -c '
import json, pathlib, sys
path = pathlib.Path(sys.argv[1])
try:
    data = json.loads(path.read_text()) if path.exists() else {}
except (OSError, json.JSONDecodeError) as exc:
    raise SystemExit(f"Cannot read {path}: {exc}")
dots = data.setdefault("dots", {})
dots["url"], dots["branch"] = sys.argv[2:4]
path.write_text(json.dumps(data, indent=4) + "\n")
' $cli_config $repo_url $branch
or exit $status

# Older versions of this rice symlinked the whole caelestia config directory
# into the repo. Convert that to a real directory before the CLI deploys
# individual managed files, otherwise it would write through the symlink.
set caelestia_config $config_home/caelestia
if test -L $caelestia_config
    set old_config (realpath $caelestia_config)
    set temp_config (mktemp -d)
    or exit 1
    cp -a $old_config/. $temp_config/
    or begin
        rm -rf $temp_config
        exit 1
    end
    rm $caelestia_config
    mkdir -p $caelestia_config
    cp -a $temp_config/. $caelestia_config/
    set copy_result $status
    rm -rf $temp_config
    if test $copy_result -ne 0
        exit $copy_result
    end
end

echo "Caelestia CLI will use $repo_url ($branch)."
echo "Important: the CLI installs the committed remote branch, not uncommitted local edits."
caelestia install
