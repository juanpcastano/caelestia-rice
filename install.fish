#!/usr/bin/env fish

# Check if running as root
if test (id -u) -eq 0
    echo "Error: Do not run this script as root or with sudo."
    echo "The script will use sudo internally when needed."
    exit 1
end

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
    if test -z "$path"
        return 1
    end
    
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
set -l aur_helper paru
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
if ! pacman -Q $aur_helper &> /dev/null
    log "$aur_helper not installed. Installing..."
    sudo pacman -S --needed git base-devel --noconfirm
    cd /tmp
    git clone https://aur.archlinux.org/$aur_helper.git
    cd $aur_helper
    makepkg -si --noconfirm
    cd ..
    rm -rf $aur_helper
    $aur_helper --gendb
    log "$aur_helper installed successfully!"
else
    log "$aur_helper is already installed."
end

# Cd into script directory
cd (dirname (status filename)) || exit 1

# Install metapackage for deps
if test -f PKGBUILD
    log 'Installing metapackage...'
    $aur_helper -Ui --noconfirm
    fish -c 'rm -f caelestia-meta-*.pkg.tar.zst' 2> /dev/null
end

# AUR packages
log 'Installing AUR packages...'
$aur_helper -S --needed ttf-ms-fonts brave-bin spotify \
    discord equicord-installer-bin opencode --noconfirm

# Ask for steam installation
input "Do you want to install Steam? [y/N] " -n
set -l steam_choice (sh-read)
if test "$steam_choice" = 'y' -o "$steam_choice" = 'Y'
    log 'Installing Steam...'
    
    # Check if multilib is enabled
    if ! grep -q '^\[multilib\]' /etc/pacman.conf
        log 'Enabling [multilib] repository...'
        sudo sed -i '/^#\[multilib\]/,/^#Include = \/etc\/pacman.d\/mirrorlist$/ { 
            s/^#\[multilib\]/[multilib]/ 
            s/^#Include = \/etc\/pacman.d\/mirrorlist$/Include = \/etc\/pacman.d\/mirrorlist/
        }' /etc/pacman.conf
        sudo pacman -Sy
    end
    
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

# Discord with Equicord - Based on official script approach
log 'Installing Discord with Equicord...'

# Try Equilotl first (as in official script), fallback to equicord-installer
if command -v Equilotl &> /dev/null
    sudo Equilotl -install -location /opt/discord
    sudo Equilotl -install-openasar -location /opt/discord
    $aur_helper -Rns equicord-installer-bin --noconfirm
else if command -v equicord-installer &> /dev/null
    log 'Using equicord-installer (new command name)...'
    sudo equicord-installer -install -location /opt/discord
    sudo equicord-installer -install-openasar -location /opt/discord
    $aur_helper -Rns equicord-installer-bin --noconfirm
else
    log 'Warning: Equicord installer not found. Please install Equicord manually.'
end

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
