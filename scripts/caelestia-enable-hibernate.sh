#!/usr/bin/env bash

# Enable resume from a disk-backed swap partition. This is intentionally an
# optional component because the swap device and bootloader are machine-specific.

set -euo pipefail

if [[ $EUID -ne 0 ]]; then
    echo "Run this script through sudo." >&2
    exit 1
fi

swap_device=""
swap_type=""
memory_kib=$(awk '/^MemTotal:/ { print $2; exit }' /proc/meminfo)
if [[ ! "$memory_kib" =~ ^[0-9]+$ ]] || (( memory_kib == 0 )); then
    echo "Could not determine the amount of installed memory." >&2
    exit 1
fi
memory_bytes=$((memory_kib * 1024))

while read -r device swap_size_bytes type; do
    [[ -z "$device" || "$device" == /dev/zram* ]] && continue
    [[ -b "$device" ]] || continue
    [[ "$swap_size_bytes" =~ ^[0-9]+$ ]] || continue
    if (( swap_size_bytes >= memory_bytes )); then
        swap_device="$device"
        swap_type="$type"
        break
    fi
done < <(swapon --show=NAME,SIZE,TYPE --bytes --noheadings)

if [[ -z "$swap_device" ]]; then
    echo "No disk-backed swap at least as large as RAM was found; hibernation was not configured." >&2
    exit 1
fi

if [[ "$swap_type" != "partition" ]]; then
    cat >&2 <<'EOF'
The available swap is a swap file. This script currently supports swap
partitions only, because swap files need a filesystem-specific resume_offset.
Create/configure a swap partition at least as large as RAM, then run this
script again.
EOF
    exit 1
fi

swap_uuid=$(blkid -s UUID -o value "$swap_device")
if [[ -z "$swap_uuid" ]]; then
    echo "Could not determine the UUID of $swap_device." >&2
    exit 1
fi

timestamp=$(date +%Y%m%d-%H%M%S)
bootloader=""
if [[ -f /boot/refind_linux.conf ]]; then
    bootloader="refind"
    cp -a /boot/refind_linux.conf "/boot/refind_linux.conf.bak.$timestamp"
elif [[ -f /etc/default/grub ]]; then
    bootloader="grub"
    cp -a /etc/default/grub "/etc/default/grub.bak.$timestamp"
elif [[ -d /boot/loader/entries ]]; then
    bootloader="systemd-boot"
    cp -a /boot/loader "/boot/loader.bak.$timestamp"
else
    echo "Could not find a supported bootloader configuration (GRUB, rEFInd, or systemd-boot)." >&2
    exit 1
fi

initramfs=""
if [[ -f /etc/mkinitcpio.conf ]] && command -v mkinitcpio >/dev/null; then
    initramfs="mkinitcpio"
elif command -v dracut >/dev/null; then
    initramfs="dracut"
else
    echo "Could not find mkinitcpio or dracut to build the resume initramfs." >&2
    exit 1
fi
if [[ "$initramfs" == "mkinitcpio" ]]; then
    cp -a /etc/mkinitcpio.conf "/etc/mkinitcpio.conf.bak.$timestamp"
    for config in /etc/mkinitcpio.conf.d/*.conf; do
        [[ -f "$config" ]] || continue
        if grep -Eq '^[[:space:]]*MODULES\+?=' "$config"; then
            cp -a "$config" "$config.bak.$timestamp"
        fi
    done
fi

# NVIDIA's preservation path needs a persistent temporary directory. Leaving
# this unset can make the driver fail its PCI freeze callback after the kernel
# has already read the hibernation image.
if [[ -d /sys/module/nvidia ]]; then
    nvidia_modprobe_conf="/etc/modprobe.d/caelestia-nvidia-hibernate.conf"
    if [[ -f "$nvidia_modprobe_conf" ]]; then
        cp -a "$nvidia_modprobe_conf" "$nvidia_modprobe_conf.bak.$timestamp"
    fi
    cat > "$nvidia_modprobe_conf" <<'EOF'
options nvidia NVreg_PreserveVideoMemoryAllocations=1 NVreg_TemporaryFilePath=/var/tmp
EOF
fi

python - "$swap_uuid" "$bootloader" "$initramfs" <<'PY'
from pathlib import Path
import re
import sys

uuid = sys.argv[1]
bootloader = sys.argv[2]
initramfs = sys.argv[3]

if initramfs == "mkinitcpio":
    config_files = [Path("/etc/mkinitcpio.conf")]
    config_files.extend(sorted(Path("/etc/mkinitcpio.conf.d").glob("*.conf")))
    for config in config_files:
        text = config.read_text()
        def remove_nvidia_modules(match):
            modules = match.group(2).split()
            modules = [module for module in modules if not module.strip('"\'') in {
                "nvidia", "nvidia_modeset", "nvidia_uvm", "nvidia_drm"
            }]
            return match.group(1) + " ".join(modules) + match.group(3)
        text = re.sub(
            r"^(MODULES\+?=\()([^)]*)(\).*)$",
            remove_nvidia_modules,
            text,
            flags=re.M,
        )
        config.write_text(text)

    mkinitcpio = Path("/etc/mkinitcpio.conf")
    text = mkinitcpio.read_text()
    match = re.search(r"^HOOKS=\(([^)]*)\)$", text, re.M)
    if not match:
        raise SystemExit("Could not find HOOKS in /etc/mkinitcpio.conf")
    hooks = match.group(1).split()
    if "resume" not in hooks:
        if "filesystems" not in hooks:
            raise SystemExit("Could not find the filesystems hook in /etc/mkinitcpio.conf")
        hooks.insert(hooks.index("filesystems"), "resume")
        text = text[:match.start()] + "HOOKS=(" + " ".join(hooks) + ")" + text[match.end():]
        mkinitcpio.write_text(text)
else:
    dracut_conf = Path("/etc/dracut.conf.d/caelestia-hibernate.conf")
    dracut_conf.parent.mkdir(parents=True, exist_ok=True)
    dracut_conf.write_text('add_dracutmodules+=" resume "\n')

resume = f"resume=UUID={uuid}"
if bootloader == "grub":
    grub = Path("/etc/default/grub")
    text = grub.read_text()
    match = re.search(
        r'^(GRUB_CMDLINE_LINUX_DEFAULT=)([\"\'])(.*)\2$',
        text,
        flags=re.M,
    )
    if match is None:
        raise SystemExit("Could not find GRUB_CMDLINE_LINUX_DEFAULT in /etc/default/grub")
    options = re.sub(r'\bresume=\S+', '', match.group(3)).strip()
    options = f"{resume} {options}".strip()
    replacement = f'{match.group(1)}{match.group(2)}{options}{match.group(2)}'
    text = text[:match.start()] + replacement + text[match.end():]
    grub.write_text(text)
    if resume not in replacement:
        raise SystemExit("Could not add the resume parameter to /etc/default/grub")
elif bootloader == "refind":
    refind = Path("/boot/refind_linux.conf")
    lines = refind.read_text().splitlines(keepends=True)
    changed = False
    for index, line in enumerate(lines):
        if not line.strip() or line.lstrip().startswith("#"):
            continue
        updated = re.sub(r'\bresume=\S+', resume, line)
        if updated == line and resume not in line:
            end = updated.rfind('"')
            if end == -1:
                continue
            updated = updated[:end].rstrip() + " " + resume + updated[end:]
        if updated != line:
            lines[index] = updated
            changed = True
    if changed:
        refind.write_text("".join(lines))
    if not any(resume in line for line in lines if line.strip() and not line.lstrip().startswith("#")):
        raise SystemExit("Could not add the resume parameter to /boot/refind_linux.conf")
elif bootloader == "systemd-boot":
    entries = list(Path("/boot/loader/entries").glob("*.conf"))
    changed = False
    for entry in entries:
        lines = entry.read_text().splitlines(keepends=True)
        for index, line in enumerate(lines):
            if line.startswith("options "):
                if resume not in line:
                    lines[index] = line.rstrip("\n") + " " + resume + "\n"
                    changed = True
                break
        else:
            continue
        entry.write_text("".join(lines))
    if not entries or not any(resume in entry.read_text() for entry in entries):
        raise SystemExit("Could not add the resume parameter to systemd-boot entries")
PY

if [[ "$initramfs" == "mkinitcpio" ]]; then
    mkinitcpio -P
else
    dracut --regenerate-all --force
fi
if [[ "$bootloader" == "grub" ]]; then
    grub-mkconfig -o /boot/grub/grub.cfg
fi

# NVIDIA needs its video-memory save/restore hooks around the system sleep
# transaction. Without these units the kernel can save the hibernation image,
# but the NVIDIA PCI device fails while that image is being restored.
if command -v systemctl >/dev/null; then
    nvidia_units=()
    for unit in nvidia-suspend.service nvidia-hibernate.service nvidia-resume.service nvidia-suspend-then-hibernate.service; do
        if systemctl list-unit-files --full --no-legend "$unit" 2>/dev/null | grep -q "^$unit"; then
            nvidia_units+=("$unit")
        fi
    done
    if ((${#nvidia_units[@]})); then
        systemctl daemon-reload
        systemctl enable "${nvidia_units[@]}"
        echo "Enabled NVIDIA power-management units: ${nvidia_units[*]}"
    fi
fi

echo "Hibernate resume enabled using $swap_device (UUID: $swap_uuid)."
