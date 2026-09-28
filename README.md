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
- **Integrated launcher** (`Super + Space`) with quick search
- **Screenshots** and integrated recording
- **Clipboard manager** with history

## 📋 Requirements

- CachyOS, Arch Linux, or another Arch-based distribution
- Fish and Git
- An AUR helper (`install.fish` bootstraps `paru` if neither `paru` nor `yay` is installed)

The Caelestia CLI installs packages and deploys the dotfiles described in `manifest.toml`. It does not install GPU drivers or configure system services; handle those through CachyOS/system settings as needed.

## 🚀 Quick Installation

```bash
git clone https://github.com/juanpcastano/caelestia-rice.git ~/.local/share/caelestia-rice
cd ~/.local/share/caelestia-rice
fish install.fish
```

`install.fish` points the CLI at this repository and runs `caelestia install`. The CLI installs the committed branch from the remote, so commit and push changes before installing them on a new machine. The CLI offers a backup of `~/.config` before deployment.

Most components in `manifest.toml` are enabled by default. `docker` and `sddm` are optional components; enable them with `caelestia install --enable-components docker,sddm` if desired. Installing those packages does not automatically configure their system services.

## Upstream and personal configuration

This repository follows the full `caelestia-dots/caelestia` project. Upstream files are merged from the `upstream` Git remote; this fork keeps its own package manifest and personal preferences.

Hyprland modules in `hypr/` follow upstream. Put supported values in `caelestia/hypr-vars.lua`; additional settings and bindings belong in `caelestia/hypr-user.lua`, which is loaded after the upstream modules. This variant uses Brave and Neovim and does not enable the upstream Firefox, VS Code/VSCodium, Zed, or Micro components.

To inspect upstream changes before updating:

```bash
git fetch upstream
git diff --stat HEAD...upstream/main
git diff HEAD...upstream/main -- manifest.toml hypr/
```

Review the full diff before merging so intentional removals and personal settings remain part of this variant.

## ⌨️ Hyprland Keybindings

### Launchers and Shell

| Shortcut              | Action              |
| --------------------- | ------------------- |
| `Super + Space`       | Open launcher       |
| `Ctrl + Alt + Delete` | Session menu        |
| `Super + N`           | Clear notifications |
| `Super + M`           | Show all panels     |
| `Super + B`           | Lock screen         |
| `Super + Alt + B`     | Restore and lock    |

### Workspaces

| Shortcut                               | Action                                 |
| -------------------------------------- | -------------------------------------- |
| `Super + 1-9,0`                        | Switch to workspace #                  |
| `Super + Scroll` or `Ctrl+Super + H/L` | Previous/next workspace                |
| `Super + Page Up/Down`                 | Previous/next workspace                |
| `Super + Shift + 1-9,0`                | Move window to workspace #             |
| `Super + Shift + H/L`                  | Move window to previous/next workspace |

### Windows

| Shortcut                 | Action                          |
| ------------------------ | ------------------------------- |
| `Super + H/J/K/L`        | Move focus (left/down/up/right) |
| `Super + Alt + H/J/K/L`  | Move window                     |
| `Super + Z` + drag       | Move window with mouse          |
| `Super + X` + drag       | Resize window with mouse        |
| `Super + Left click`     | Move window                     |
| `Super + Right click`    | Resize window                   |
| `Super + -/+`            | Adjust split ratio              |
| `Super + P`              | Toggle floating window          |
| `Super + F`              | Fullscreen                      |
| `Super + Alt + F`        | Fullscreen with borders         |
| `Super + Alt + P`        | Picture-in-Picture mode         |
| `Super + C`              | Close active window             |
| `Ctrl + Super + \`       | Center window                   |
| `Ctrl + Super + Alt + \` | Center and resize (55% x 70%)   |

### Applications

| Shortcut    | Action                |
| ----------- | --------------------- |
| `Super + T` | Terminal (Foot)       |
| `Super + W` | Browser (Brave)       |
| `Super + E` | File Manager (Thunar) |

### Screenshots

| Shortcut                  | Action                         |
| ------------------------- | ------------------------------ |
| `Print`                   | Full screenshot → clipboard    |
| `Super + Shift + S`       | Capture region                 |
| `Super + Shift + Alt + S` | Capture region (freeze screen) |
| `Ctrl + Alt + R`          | Record screen                  |
| `Super + Alt + R`         | Record screen with audio       |
| `Super + Shift + Alt + R` | Record region                  |

### Clipboard and Emoji

| Shortcut                 | Action                          |
| ------------------------ | ------------------------------- |
| `Super + V`              | Clipboard history               |
| `Super + Alt + V`        | Clipboard history (delete item) |
| `Super + .`              | Emoji picker                    |
| `Ctrl + Shift + Alt + V` | Paste last item (alternative)   |
| `Super + Shift + C`      | Color picker                    |

### Brightness and Volume (Multimedia Keys)

| Shortcut                           | Action                       |
| ---------------------------------- | ---------------------------- |
| `XF86MonBrightnessUp/Down`         | Increase/Decrease brightness |
| `XF86AudioRaiseVolume/LowerVolume` | Increase/Decrease volume     |
| `XF86AudioMute`                    | Mute output                  |
| `XF86AudioMicMute`                 | Mute microphone              |
| `Super + Shift + M`                | Mute output                  |

### Media (Multimedia Control)

| Shortcut               | Action         |
| ---------------------- | -------------- |
| `Ctrl + Super + Space` | Play/Pause     |
| `XF86AudioPlay/Pause`  | Play/Pause     |
| `Ctrl + Super + =`     | Next track     |
| `XF86AudioNext`        | Next track     |
| `Ctrl + Super + -`     | Previous track |
| `XF86AudioPrev`        | Previous track |
| `XF86AudioStop`        | Stop           |

### Shell and Restart

| Shortcut                   | Action        |
| -------------------------- | ------------- |
| `Ctrl + Super + Shift + R` | Kill shell    |
| `Ctrl + Super + Alt + R`   | Restart shell |

## 📝 Manual Installation

Install the Caelestia CLI from the AUR, set its dots source to this repository, and run its installer:

```bash
paru -S caelestia-cli
mkdir -p ~/.config/caelestia
cat > ~/.config/caelestia/cli.json <<'EOF'
{
  "dots": {
    "url": "https://github.com/juanpcastano/caelestia-rice.git",
    "branch": "main"
  }
}
EOF
caelestia install
```

## 🔄 Updating

Push your changes to the configured branch, then run:

```bash
caelestia update
```

## 🐛 Troubleshooting

### Hyprland won't start

- Check config diagnostics with `hyprctl configerrors`
- Check the logs: `hyprctl logs`

### Shell doesn't appear

- Verify `caelestia` is installed: `command -v caelestia`
- Restart the shell: `Ctrl + Super + Alt + R`

## 📄 License

This project is under the GPL-3.0 license.

## 🙏 Credits

- **Original project:** [caelestia-dots/caelestia](https://github.com/caelestia-dots/caelestia) - Created by [@caelestia-dots](https://github.com/caelestia-dots)
- **Fork by:** [@juanpcastano](https://github.com/juanpcastano)

---

**Note:** This rice is designed to work as a complete system. The configurations are interconnected to provide a cohesive experience.
