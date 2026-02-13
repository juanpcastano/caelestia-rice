#!/usr/bin/env fish

# Helper funcs
function _out -a colour text
    set_color $colour
    echo $argv[3..] -- ":: $text"
    set_color normal
end

function log -a text
    _out cyan $text $argv[2..]
end

function input -a text
    _out blue $text $argv[2..]
end

function sh-read
    sh -c 'read a && echo -n "$a"' || exit 1
end

function confirm-overwrite -a path
    if test -e $path -o -L $path
        input "$path already exists. Overwrite? [Y/n] " -n
        set -l confirm (sh-read)

        if test "$confirm" = 'n' -o "$confirm" = 'N'
            log 'Skipping...'
            return 1
        else
            log 'Removing...'
            rm -rf $path
        end
    end
    return 0
end

# Variables
set -q XDG_CONFIG_HOME && set -l config $XDG_CONFIG_HOME || set -l config $HOME/.config
set -q XDG_STATE_HOME && set -l state $XDG_STATE_HOME || set -l state $HOME/.local/state

# ASCII Art and greeting
set_color magenta
echo '╭─────────────────────────────────────────────────╮'
echo '│      ______           __          __  _         │'
echo '│     / ____/___ ____  / /__  _____/ /_(_)___ _   │'
echo '│    / /   / __ `/ _ \/ / _ \/ ___/ __/ / __ `/   │'
echo '│   / /___/ /_/ /  __/ /  __(__  ) /_/ / /_/ /    │'
echo '│   \____/\__,_/\___/_/\___/____/\__/_/\__,_/     │'
echo '│                                                 │'
echo '╰─────────────────────────────────────────────────╯'
set_color normal

log 'Welcome to the Caelestia rice installer!'
log 'This script will install and configure your system.'
echo

# Check and install paru
if ! pacman -Q paru &> /dev/null
    log "paru not installed. Installing..."
    sudo pacman -S --needed git base-devel --noconfirm
    cd /tmp
    git clone https://aur.archlinux.org/paru.git
    cd paru
    makepkg -si --noconfirm
    cd ..
    rm -rf paru
    paru --gendb
    log "paru installed successfully!"
else
    log "paru is already installed."
end

# Cd into script directory
cd (dirname (status filename)) || exit 1

# Install packages without asking (except steam)
log 'Installing base packages...'

# Core packages from official repos
sudo pacman -S --needed vim python python-pip nodejs go rust java-runtime-common \
    ttf-ms-fonts thunar uwsm wget luarocks unzip cava obs-studio pavucontrol mpv \
    sddm --noconfirm

# AUR packages
log 'Installing AUR packages...'
paru -S --needed nvim zen-browser-bin spicetify-cli spicetify-marketplace-bin \
    equicord-installer-bin opencode-bin --noconfirm

# Ask for steam installation
input "Do you want to install Steam? [y/N] " -n
set -l steam_choice (sh-read)
if test "$steam_choice" = 'y' -o "$steam_choice" = 'Y'
    log 'Installing Steam...'
    sudo pacman -S --needed steam --noconfirm
else
    log 'Skipping Steam installation.'
end

# Setup symlinks for configurations
echo
log 'Setting up configuration symlinks...'

# NVIM
if confirm-overwrite $config/nvim
    log 'Installing nvim config...'
    ln -s (realpath nvim) $config/nvim
end

# Zen Browser
set -l chrome $HOME/.zen/*/chrome
if confirm-overwrite $chrome/userChrome.css
    log 'Installing zen userChrome...'
    ln -s (realpath zen/userChrome.css) $chrome/userChrome.css
end

# Zen native app
set -l hosts $HOME/.mozilla/native-messaging-hosts
set -l lib $HOME/.local/lib/caelestia

if confirm-overwrite $hosts/caelestiafox.json
    log 'Installing zen native app manifest...'
    mkdir -p $hosts
    cp zen/native_app/manifest.json $hosts/caelestiafox.json
    sed -i "s|{{ \$lib }}|$lib|g" $hosts/caelestiafox.json
end

if confirm-overwrite $lib/caelestiafox
    log 'Installing zen native app...'
    mkdir -p $lib
    ln -s (realpath zen/native_app/app.fish) $lib/caelestiafox
end

# Spotify (spicetify)
log 'Setting up Spotify (spicetify)...'
sudo chmod a+wr /opt/spotify
sudo chmod a+wr /opt/spotify/Apps -R
spicetify backup apply

if confirm-overwrite $config/spicetify
    log 'Installing spicetify config...'
    ln -s (realpath spicetify) $config/spicetify
    spicetify config current_theme caelestia color_scheme caelestia custom_apps marketplace 2> /dev/null
    spicetify apply
end

# Discord with Equicord
log 'Installing Equicord...'
paru -S --needed discord equicord-installer-bin --noconfirm
sudo Equilotl -install -location /opt/discord
sudo Equilotl -install-openasar -location /opt/discord
paru -Rns equicord-installer-bin --noconfirm

# SDDM setup
log 'Setting up SDDM...'
sudo systemctl enable sddm.service

# Create symlink for SDDM config in /etc
if test -d sddm.conf.d
    log 'Linking SDDM configuration to /etc/sddm.conf.d/'
    sudo mkdir -p /etc/sddm.conf.d
    for file in sddm.conf.d/*
        set -l filename (basename $file)
        if test -e /etc/sddm.conf.d/$filename
            log "/etc/sddm.conf.d/$filename already exists. Backing up..."
            sudo mv /etc/sddm.conf.d/$filename /etc/sddm.conf.d/$filename.bak
        end
        sudo ln -sf (realpath $file) /etc/sddm.conf.d/$filename
    end
end

# Install metapackage for deps (if exists)
if test -f PKGBUILD
    log 'Installing metapackage...'
    paru -Ui --noconfirm
    fish -c 'rm -f caelestia-meta-*.pkg.tar.zst' 2> /dev/null
end

# Install hypr* configs
if confirm-overwrite $config/hypr
    log 'Installing hypr* configs...'
    ln -s (realpath hypr) $config/hypr
    if command -v hyprctl &> /dev/null
        hyprctl reload 2> /dev/null
    end
end

# Starship
if confirm-overwrite $config/starship.toml
    log 'Installing starship config...'
    ln -s (realpath starship.toml) $config/starship.toml
end

# Foot
if confirm-overwrite $config/foot
    log 'Installing foot config...'
    ln -s (realpath foot) $config/foot
end

# Fish
if confirm-overwrite $config/fish
    log 'Installing fish config...'
    ln -s (realpath fish) $config/fish
end

# Fastfetch
if confirm-overwrite $config/fastfetch
    log 'Installing fastfetch config...'
    ln -s (realpath fastfetch) $config/fastfetch
end

# Uwsm
if confirm-overwrite $config/uwsm
    log 'Installing uwsm config...'
    ln -s (realpath uwsm) $config/uwsm
end

# Btop
if confirm-overwrite $config/btop
    log 'Installing btop config...'
    ln -s (realpath btop) $config/btop
end

# Generate scheme stuff if needed
if ! test -f $state/caelestia/scheme.json
    if command -v caelestia &> /dev/null
        caelestia scheme set -n shadotheme
        sleep .5
        if command -v hyprctl &> /dev/null
            hyprctl reload 2> /dev/null
        end
    end
end

# Start the shell if caelestia is available
if command -v caelestia &> /dev/null
    caelestia shell -d > /dev/null 2>&1
end

echo
log 'Installation complete!'
log 'Please reboot your system to apply all changes.'
