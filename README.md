# Caelestia Rice

> **🍴 Este es un fork personal de [caelestia-dots/caelestia](https://github.com/caelestia-dots/caelestia)**
>
> Todo el crédito por el trabajo original va para [@caelestia-dots](https://github.com/caelestia-dots). Este fork contiene mis modificaciones personales y configuraciones adaptadas a mis necesidades.

Una configuración completa y elegante de Hyprland sin la intención de ser óptimo, simplemente que me da más serotonina que lo que de normal me da usar el pc

## ✨ Características

- **Hyprland** como compositor Wayland con animaciones fluidas
- **Shell personalizado (caelestia)** con notificaciones, widgets y panel
- **Temas dinámicos** con esquemas de colores automáticos
- **Configuraciones integradas** para NVim, Fish, Foot, Starship, Btop y más
- **Gestión de ventanas** optimizada con keybindings intuitivos
- **Launcher integrado** (Super) con búsqueda rápida
- **Capturas de pantalla** y grabación integradas
- **Gestor de portapapeles** con historial

## 📋 Requisitos

- Fish shell
- Git
- Base-devel (para compilar paquetes AUR)

> **⚠️ Advertencia importante:**
> El script de instalación crea symlinks a los archivos de configuración, por lo que **NO puedes mover ni eliminar la carpeta del repositorio** después de instalar. Se recomienda clonar en `~/.local/share/caelestia-rice`.

## 🚀 Instalación Rápida

```bash
git clone https://github.com/juanpcastano/caelestia-rice.git ~/.local/share/caelestia-rice
~/.local/share/caelestia-rice/install.fish
```

Reinicia tu sistema después de la instalación.

## 🔧 Qué Instala el Script

### Paquetes Oficiales (pacman)

- **Núcleo:** vim, neovim, python, python-pip, nodejs, go, rust, jre-openjdk
- **Sistema:** hyprland, uwsm, xdg-desktop-portal-hyprland, xdg-desktop-portal-gtk
- **Apps:** thunar, foot, brave, obs-studio, pavucontrol, mpv, sddm
- **Herramientas:** wireplumber, wl-clipboard, cliphist, hyprpicker, inotify-tools, app2unit, trash-cli
- **Extras:** btop, fastfetch, starship, jq, eza, cava, luarocks, unzip, wget

### Paquetes AUR (paru/yay)

- ttf-ms-fonts
- brave-bin
- spotify
- discord
- equicord-installer-bin
- opencode
- ttf-jetbrains-mono-nerd

### Steam (opcional)

El script pregunta si deseas instalar Steam. Si aceptas:

- Habilita automáticamente el repositorio `[multilib]`
- Instala Steam desde los repositorios oficiales

### Configuraciones que Configura

1. **NVim** - Editor con configuración completa
2. **Hyprland** - Compositor con todas las configs
3. **Fish** - Shell con temas y funciones
4. **Foot** - Terminal emulador
5. **Starship** - Prompt personalizado
6. **Fastfetch** - Información del sistema
7. **UWSM** - Session manager
8. **Btop** - Monitor de recursos
9. **SDDM** - Login manager (habilitado automáticamente)
10. **Discord** - Con Equicord y OpenAsar instalados

### Discord con Equicord

El script instala automáticamente Equicord en Discord usando el instalador oficial.

## ⌨️ Keybindings de Hyprland

### Lanzadores y Shell

| Atajo                 | Acción                    |
| --------------------- | ------------------------- |
| `Super`               | Abrir launcher            |
| `Super` + `Tecla`     | Interrumpir launcher      |
| `Ctrl + Alt + Delete` | Menú de sesión            |
| `Super + N`           | Limpiar notificaciones    |
| `Super + M`           | Mostrar todos los paneles |
| `Super + B`           | Bloquear pantalla         |
| `Super + Alt + B`     | Restaurar y bloquear      |

### Workspaces (Escritorios)

| Atajo                                 | Acción                                        |
| ------------------------------------- | --------------------------------------------- |
| `Super + 1-9,0`                       | Cambiar al workspace #                        |
| `Super + Scroll` o `Ctrl+Super + H/L` | Workspace anterior/siguiente                  |
| `Super + Page Up/Down`                | Workspace anterior/siguiente                  |
| `Super + Shift + 1-9,0`               | Mover ventana al workspace #                  |
| `Super + Shift + H/L`                 | Mover ventana al workspace anterior/siguiente |

### Ventanas

| Atajo                    | Acción                                      |
| ------------------------ | ------------------------------------------- |
| `Super + H/J/K/L`        | Mover foco (izquierda/abajo/arriba/derecha) |
| `Super + Alt + H/J/K/L`  | Mover ventana                               |
| `Super + Z` + arrastrar  | Mover ventana con mouse                     |
| `Super + X` + arrastrar  | Redimensionar ventana con mouse             |
| `Super + Clic izquierdo` | Mover ventana                               |
| `Super + Clic derecho`   | Redimensionar ventana                       |
| `Super + -/+`            | Ajustar ratio de división                   |
| `Super + P`              | Alternar ventana flotante                   |
| `Super + F`              | Pantalla completa                           |
| `Super + Alt + F`        | Pantalla completa con bordes                |
| `Super + Alt + P`        | Modo Picture-in-Picture                     |
| `Super + C`              | Cerrar ventana activa                       |
| `Ctrl + Super + \`       | Centrar ventana                             |
| `Ctrl + Super + Alt + \` | Centrar y redimensionar (55% x 70%)         |

### Aplicaciones

| Atajo       | Acción                          |
| ----------- | ------------------------------- |
| `Super + T` | Terminal (Foot)                 |
| `Super + W` | Navegador (Brave)               |
| `Super + E` | Explorador de archivos (Thunar) |

### Capturas de Pantalla

| Atajo                     | Acción                                    |
| ------------------------- | ----------------------------------------- |
| `Print`                   | Capturar pantalla completa → portapapeles |
| `Super + Shift + S`       | Capturar región                           |
| `Super + Shift + Alt + S` | Capturar región (congelar pantalla)       |
| `Ctrl + Alt + R`          | Grabar pantalla                           |
| `Super + Alt + R`         | Grabar pantalla con audio                 |
| `Super + Shift + Alt + R` | Grabar región                             |

### Portapapeles y Emoji

| Atajo                    | Acción                                     |
| ------------------------ | ------------------------------------------ |
| `Super + V`              | Historial del portapapeles                 |
| `Super + Alt + V`        | Historial del portapapeles (eliminar ítem) |
| `Super + .`              | Selector de emoji                          |
| `Ctrl + Shift + Alt + V` | Pegar último ítem (alternativo)            |
| `Super + Shift + C`      | Selector de color                          |

### Brillo y Volumen (Teclas Multimedia)

| Atajo                              | Acción              |
| ---------------------------------- | ------------------- |
| `XF86MonBrightnessUp/Down`         | Subir/Bajar brillo  |
| `XF86AudioRaiseVolume/LowerVolume` | Subir/Bajar volumen |
| `XF86AudioMute`                    | Silenciar salida    |
| `XF86AudioMicMute`                 | Silenciar micrófono |
| `Super + Shift + M`                | Silenciar salida    |

### Media (Control multimedia)

| Atajo                  | Acción          |
| ---------------------- | --------------- |
| `Ctrl + Super + Space` | Play/Pause      |
| `XF86AudioPlay/Pause`  | Play/Pause      |
| `Ctrl + Super + =`     | Siguiente pista |
| `XF86AudioNext`        | Siguiente pista |
| `Ctrl + Super + -`     | Pista anterior  |
| `XF86AudioPrev`        | Pista anterior  |
| `XF86AudioStop`        | Detener         |

### Shell y Reinicio

| Atajo                      | Acción          |
| -------------------------- | --------------- |
| `Ctrl + Super + Shift + R` | Matar shell     |
| `Ctrl + Super + Alt + R`   | Reiniciar shell |

## 📝 Instalación Manual

Si prefieres instalar manualmente:

### Dependencias

```bash
# Paquetes oficiales
sudo pacman -S hyprland xdg-desktop-portal-hyprland xdg-desktop-portal-gtk \
    hyprpicker wl-clipboard cliphist inotify-tools app2unit wireplumber \
    trash-cli foot fish fastfetch starship btop jq eza adw-gtk-theme \
    papirus-icon-theme qt5ct-kde qt6ct-kde ttf-jetbrains-mono-nerd

# Desde AUR
paru -S caelestia-meta caelestia-shell caelestia-cli
```

### Configuraciones

Copia o crea symlinks de las carpetas:

- `hypr/` → `~/.config/hypr/`
- `foot/` → `~/.config/foot/`
- `fish/` → `~/.config/fish/`
- `fastfetch/` → `~/.config/fastfetch/`
- `uwsm/` → `~/.config/uwsm/`
- `btop/` → `~/.config/btop/`
- `nvim/` → `~/.config/nvim/`
- `starship.toml` → `~/.config/starship.toml`

## 🔄 Actualización

Para actualizar el rice:

```bash
cd ~/.local/share/caelestia
git pull
```

Luego actualiza los paquetes AUR:

```bash
paru
```

## 🐛 Solución de Problemas

### Hyprland no inicia

- Verifica que no moviste la carpeta del repositorio
- Comprueba los logs: `hyprctl logs`

### El shell no aparece

- Verifica que `caelestia` está instalado: `which caelestia`
- Reinicia el shell: `Ctrl + Super + Alt + R`

### Discord sin Equicord

- Reinstala manualmente: `sudo equicord-installer -install -location /opt/discord`

## 📄 Licencia

Este proyecto está bajo la licencia GPL-3.0.

## 🙏 Créditos

- **Proyecto original:** [caelestia-dots/caelestia](https://github.com/caelestia-dots/caelestia) - Creado por [@caelestia-dots](https://github.com/caelestia-dots)
- **Fork por:** [@juanpcastano](https://github.com/juanpcastano)

---

**Nota:** Este rice está diseñado para funcionar como un sistema completo. Las configuraciones están interconectadas para proporcionar una experiencia cohesive.
