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

The Caelestia CLI installs packages and deploys the dotfiles described in `manifest.toml`. This setup targets Arch-compatible systems with `pacman`/`makepkg` and AUR support. It does not install GPU drivers or enable system services; handle those through the distribution's settings as needed.

## 🚀 Quick Installation

```bash
git clone https://github.com/juanpcastano/caelestia-rice.git ~/.local/share/caelestia-rice
cd ~/.local/share/caelestia-rice
fish install.fish
```

`install.fish` points the CLI at this repository and runs `caelestia install`. The CLI installs the committed branch from the remote, so commit and push changes before installing them on a new machine. The CLI offers a backup of `~/.config` before deployment.

Most components in `manifest.toml` are enabled by default. `uwsm`, `greetd`, `spotify`, `discord`, and `docker` are optional. Enable the greetd workflow with `caelestia install --enable-components greetd`; this installs greetd and the upstream Caelestia Greeter with its dedicated Hyprland compositor. Enable multiple optional components together, for example `caelestia install --enable-components greetd,spotify,discord`. Equibop is a separate client and leaves the official Discord installed. The `auth` component is enabled by default and installs `hyprpolkitagent`.

The default `automount` component installs UDisks2's GVFS volume monitor, `udiskie` as a user automount daemon, a generic Polkit rule allowing filesystem mounts from an active local desktop session, and UDev rules that automatically select ordinary GPT data partitions for mounting. EFI, recovery, reserved, and swap partition types are not selected. No disk UUIDs or labels are hardcoded. Existing `/etc/fstab` entries are intentionally left untouched; remove a static entry manually only after verifying that the service mounts the volume at `/run/media/$USER/<label>` and that applications such as Steam use the new path.

## Migrating to CachyOS or another Arch-based distro

CachyOS uses the same `pacman` package ecosystem, so the normal installation above should deploy the same rice without a distro-specific manifest. Push your latest dotfiles first, then clone this repository and run `fish install.fish` on the new system. Review the installer backup before replacing existing configuration.

The repository contains the shared configuration, but intentionally does not version generated or machine-local state such as `caelestia/monitors/`, `caelestia/shell.json`, `hypr/scheme/current.lua`, `fish/fish_variables`, and `btop/themes/`. Recreate or copy any personal choices from these locations if you want them on the new install. Also configure hardware-specific items—GPU drivers, enabled services, and display setup—on CachyOS; the manifest installs packages but does not configure those system settings. The optional `greetd` component installs the upstream Caelestia Greeter, which uses a dedicated Hyprland compositor and supports multi-monitor login screens. The rice reapplies the user's Hyprland input and cursor preferences to the generated greeter: US international keyboard layout with Caps Lock as Escape, NumLock enabled, flat mouse acceleration at sensitivity 0, no natural scrolling, and the `Graphite-dark-nord-cursors` cursor theme at size 16. Its installer also adapts the shutdown command to Hyprland 0.56+'s `hl.dsp.exit()` syntax and keeps both the wallpaper and its wallpaper-derived colors observable while the greeter is running. The greeter installer creates its own backup and restore command; it does not modify the user's normal Hyprland configuration.

## Upstream and personal configuration

This repository follows the full `caelestia-dots/caelestia` project. Upstream files are merged from the `upstream` Git remote; this fork keeps its own package manifest and personal preferences.

Hyprland modules in `hypr/` follow upstream. Put supported values in `caelestia/hypr-vars.lua`; additional settings and bindings belong in `caelestia/hypr-user.lua`, which is loaded after the upstream modules. This variant uses Brave and Neovim and does not enable the upstream Firefox, VS Code/VSCodium, Zed, or Micro components.

OpenCode's global TUI preferences are kept in `opencode/cli.json` and deployed to `~/.config/opencode/cli.json` by the `opencode` manifest component. OpenCode does not support project-local CLI preferences, so this keeps its `system` theme and other TUI settings portable with the dotfiles.

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

#### CachyOS: `noctalia-qs` is installed instead of `quickshell-git`

CachyOS may satisfy Caelestia's `quickshell-git` dependency with its
`noctalia-qs` package. If Hyprland starts with a blank screen and the shell
does not load, replace it with the actual AUR package:

```bash
sudo pacman -Rdd noctalia-qs
paru --aur -S quickshell-git
```

Then reboot. Verify that `quickshell-git` is installed and `noctalia-qs` is
not:

```bash
pacman -Q quickshell-git
pacman -Q noctalia-qs
```

#### CachyOS: Node fails with `libsimdjson.so.33`

If `node -v` fails with a missing `libsimdjson` library while installing the
Spotify/Spicetify component, install the packages from the `extra` repository:

```bash
sudo pacman -S extra/nodejs extra/simdjson
```

Confirm that `node -v` works before running `fish install.fish` again.

## 📄 License

This project is under the GPL-3.0 license.

## 🙏 Credits

- **Original project:** [caelestia-dots/caelestia](https://github.com/caelestia-dots/caelestia) - Created by [@caelestia-dots](https://github.com/caelestia-dots)
- **Fork by:** [@juanpcastano](https://github.com/juanpcastano)

---

**Note:** This rice is designed to work as a complete system. The configurations are interconnected to provide a cohesive experience.
