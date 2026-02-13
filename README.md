# Caelestia Rice

> **🍴 This is a personal fork of [caelestia-dots/caelestia](https://github.com/caelestia-dots/caelestia)**
>
> All credit for the original work goes to [@caelestia-dots](https://github.com/caelestia-dots). This fork contains my personal modifications and configurations adapted to my needs.

A complete and elegant Hyprland configuration not meant to be optimal, just gives me more serotonin than what I normally get from using the PC

## ✨ Features

- **Hyprland** as Wayland compositor with smooth animations
- **Custom shell (caelestia)** with notifications, widgets and panel
- **Dynamic themes** with automatic color schemes
- **Integrated configurations** for NVim, Fish, Foot, Starship, Btop and more
- **Optimized window management** with intuitive keybindings
- **Integrated launcher** (Super) with quick search
- **Screenshots** and integrated recording
- **Clipboard manager** with history

## 📋 Requirements

- Fish shell
- Git
- Base-devel (to build AUR packages)

> **⚠️ Important Warning:**
> The installation script creates symlinks to the configuration files, so **you CANNOT move or delete the repository folder** after installing. It's recommended to clone to `~/.local/share/caelestia-rice`.

## 🚀 Quick Installation

```bash
git clone https://github.com/juanpcastano/caelestia-rice.git ~/.local/share/caelestia-rice
~/.local/share/caelestia-rice/install.fish
```

Reboot your system after installation.

## 🔧 What the Script Installs

### Official Packages (pacman)

- **Core:** vim, neovim, python, python-pip, nodejs, go, rust, jre-openjdk
- **System:** hyprland, uwsm, xdg-desktop-portal-hyprland, xdg-desktop-portal-gtk
- **Apps:** thunar, foot, brave, obs-studio, pavucontrol, mpv, sddm
- **Tools:** wireplumber, wl-clipboard, cliphist, hyprpicker, inotify-tools, app2unit, trash-cli
- **Extras:** btop, fastfetch, starship, jq, eza, cava, luarocks, unzip, wget

### AUR Packages (paru/yay)

- ttf-ms-fonts
- brave-bin
- spotify
- discord
- equicord-installer-bin
- opencode
- ttf-jetbrains-mono-nerd

### Steam (optional)

The script asks if you want to install Steam. If you accept:

- Automatically enables the `[multilib]` repository
- Installs Steam from official repositories

### Configurations Set Up

1. **NVim** - Editor with complete configuration
2. **Hyprland** - Compositor with all configs
3. **Fish** - Shell with themes and functions
4. **Foot** - Terminal emulator
5. **Starship** - Custom prompt
6. **Fastfetch** - System information
7. **UWSM** - Session manager
8. **Btop** - Resource monitor
9. **SDDM** - Login manager (automatically enabled)
10. **Discord** - With Equicord and OpenAsar installed

### Discord with Equicord

The script automatically installs Equicord on Discord using the official installer.

## ⌨️ Hyprland Keybindings

### Launchers and Shell

| Shortcut              | Action                    |
| --------------------- | ------------------------- |
| `Super`               | Open launcher             |
| `Super` + `Key`       | Interrupt launcher        |
| `Ctrl + Alt + Delete` | Session menu              |
| `Super + N`           | Clear notifications       |
| `Super + M`           | Show all panels           |
| `Super + B`           | Lock screen               |
| `Super + Alt + B`     | Restore and lock          |

### Workspaces

| Shortcut                              | Action                                        |
| ------------------------------------- | --------------------------------------------- |
| `Super + 1-9,0`                       | Switch to workspace #                         |
| `Super + Scroll` or `Ctrl+Super + H/L`| Previous/next workspace                       |
| `Super + Page Up/Down`                | Previous/next workspace                       |
| `Super + Shift + 1-9,0`               | Move window to workspace #                    |
| `Super + Shift + H/L`                 | Move window to previous/next workspace        |

### Windows

| Shortcut                 | Action                                      |
| ------------------------ | ------------------------------------------- |
| `Super + H/J/K/L`        | Move focus (left/down/up/right)             |
| `Super + Alt + H/J/K/L`  | Move window                                 |
| `Super + Z` + drag       | Move window with mouse                      |
| `Super + X` + drag       | Resize window with mouse                    |
| `Super + Left click`     | Move window                                 |
| `Super + Right click`    | Resize window                               |
| `Super + -/+`            | Adjust split ratio                          |
| `Super + P`              | Toggle floating window                      |
| `Super + F`              | Fullscreen                                  |
| `Super + Alt + F`        | Fullscreen with borders                     |
| `Super + Alt + P`        | Picture-in-Picture mode                     |
| `Super + C`              | Close active window                         |
| `Ctrl + Super + \`       | Center window                               |
| `Ctrl + Super + Alt + \` | Center and resize (55% x 70%)               |

### Applications

| Shortcut    | Action                    |
| ----------- | ------------------------- |
| `Super + T` | Terminal (Foot)           |
| `Super + W` | Browser (Brave)           |
| `Super + E` | File Manager (Thunar)     |

### Screenshots

| Shortcut                  | Action                                    |
| ------------------------- | ----------------------------------------- |
| `Print`                   | Full screenshot → clipboard               |
| `Super + Shift + S`       | Capture region                            |
| `Super + Shift + Alt + S` | Capture region (freeze screen)            |
| `Ctrl + Alt + R`          | Record screen                             |
| `Super + Alt + R`         | Record screen with audio                  |
| `Super + Shift + Alt + R` | Record region                             |

### Clipboard and Emoji

| Shortcut                 | Action                                     |
| ------------------------ | ------------------------------------------ |
| `Super + V`              | Clipboard history                          |
| `Super + Alt + V`        | Clipboard history (delete item)            |
| `Super + .`              | Emoji picker                               |
| `Ctrl + Shift + Alt + V` | Paste last item (alternative)              |
| `Super + Shift + C`      | Color picker                               |

### Brightness and Volume (Multimedia Keys)

| Shortcut                           | Action              |
| ---------------------------------- | ------------------- |
| `XF86MonBrightnessUp/Down`         | Increase/Decrease brightness |
| `XF86AudioRaiseVolume/LowerVolume` | Increase/Decrease volume     |
| `XF86AudioMute`                    | Mute output         |
| `XF86AudioMicMute`                 | Mute microphone     |
| `Super + Shift + M`                | Mute output         |

### Media (Multimedia Control)

| Shortcut               | Action          |
| ---------------------- | --------------- |
| `Ctrl + Super + Space` | Play/Pause      |
| `XF86AudioPlay/Pause`  | Play/Pause      |
| `Ctrl + Super + =`     | Next track      |
| `XF86AudioNext`        | Next track      |
| `Ctrl + Super + -`     | Previous track  |
| `XF86AudioPrev`        | Previous track  |
| `XF86AudioStop`        | Stop            |

### Shell and Restart

| Shortcut                   | Action          |
| -------------------------- | --------------- |
| `Ctrl + Super + Shift + R` | Kill shell      |
| `Ctrl + Super + Alt + R`   | Restart shell   |

## 📝 Manual Installation

If you prefer to install manually:

### Dependencies

```bash
# Official packages
sudo pacman -S hyprland xdg-desktop-portal-hyprland xdg-desktop-portal-gtk \
    hyprpicker wl-clipboard cliphist inotify-tools app2unit wireplumber \
    trash-cli foot fish fastfetch starship btop jq eza adw-gtk-theme \
    papirus-icon-theme qt5ct-kde qt6ct-kde ttf-jetbrains-mono-nerd

# From AUR
paru -S caelestia-meta caelestia-shell caelestia-cli
```

### Configurations

Copy or create symlinks of the folders:

- `hypr/` → `~/.config/hypr/`
- `foot/` → `~/.config/foot/`
- `fish/` → `~/.config/fish/`
- `fastfetch/` → `~/.config/fastfetch/`
- `uwsm/` → `~/.config/uwsm/`
- `btop/` → `~/.config/btop/`
- `nvim/` → `~/.config/nvim/`
- `starship.toml` → `~/.config/starship.toml`

## 🔄 Updating

To update the rice:

```bash
cd ~/.local/share/caelestia
git pull
```

Then update AUR packages:

```bash
paru
```

## 🐛 Troubleshooting

### Hyprland won't start

- Verify you didn't move the repository folder
- Check the logs: `hyprctl logs`

### Shell doesn't appear

- Verify `caelestia` is installed: `which caelestia`
- Restart the shell: `Ctrl + Super + Alt + R`

### Discord without Equicord

- Reinstall manually: `sudo equicord-installer -install -location /opt/discord`

## 📄 License

This project is under the GPL-3.0 license.

## 🙏 Credits

- **Original project:** [caelestia-dots/caelestia](https://github.com/caelestia-dots/caelestia) - Created by [@caelestia-dots](https://github.com/caelestia-dots)
- **Fork by:** [@juanpcastano](https://github.com/juanpcastano)

---

**Note:** This rice is designed to work as a complete system. The configurations are interconnected to provide a cohesive experience.
