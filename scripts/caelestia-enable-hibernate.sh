#!/usr/bin/env bash

# Enable resume from a disk-backed swap partition. This is intentionally an
# optional component because the swap device and bootloader are machine-specific.

set -euo pipefail

if [[ $EUID -ne 0 ]]; then
    echo "Run this script through sudo." >&2
    exit 1
fi

swap_device=""
memory_kib=$(awk '/^MemTotal:/ { print $2; exit }' /proc/meminfo)
if [[ ! "$memory_kib" =~ ^[0-9]+$ ]] || (( memory_kib == 0 )); then
    echo "Could not determine the amount of installed memory." >&2
    exit 1
fi
memory_bytes=$((memory_kib * 1024))

while read -r device swap_size_bytes; do
    [[ -z "$device" || "$device" == /dev/zram* ]] && continue
    [[ -b "$device" ]] || continue
    [[ "$swap_size_bytes" =~ ^[0-9]+$ ]] || continue
    if (( swap_size_bytes >= memory_bytes )); then
        swap_device="$device"
        break
    fi
done < <(swapon --show=NAME,SIZE --bytes --noheadings)

if [[ -z "$swap_device" ]]; then
    echo "No disk-backed swap at least as large as RAM was found; hibernation was not configured." >&2
    exit 1
fi

swap_uuid=$(blkid -s UUID -o value "$swap_device")
if [[ -z "$swap_uuid" ]]; then
    echo "Could not determine the UUID of $swap_device." >&2
    exit 1
fi

timestamp=$(date +%Y%m%d-%H%M%S)
cp -a /etc/mkinitcpio.conf "/etc/mkinitcpio.conf.bak.$timestamp"

bootloader=""
if [[ -f /etc/default/grub ]]; then
    bootloader="grub"
    cp -a /etc/default/grub "/etc/default/grub.bak.$timestamp"
elif [[ -f /boot/refind_linux.conf ]]; then
    bootloader="refind"
    cp -a /boot/refind_linux.conf "/boot/refind_linux.conf.bak.$timestamp"
else
    echo "Could not find a supported bootloader configuration (GRUB or rEFInd)." >&2
    exit 1
fi

python - "$swap_uuid" "$bootloader" <<'PY'
from pathlib import Path
import re
import sys

uuid = sys.argv[1]
bootloader = sys.argv[2]

mkinitcpio = Path("/etc/mkinitcpio.conf")
text = mkinitcpio.read_text()
match = re.search(r"^HOOKS=\(([^)]*)\)$", text, re.M)
if not match:
    raise SystemExit("Could not find HOOKS in /etc/mkinitcpio.conf")
hooks = match.group(1).split()
if "resume" not in hooks:
    hooks.insert(hooks.index("filesystems"), "resume")
    text = text[:match.start()] + "HOOKS=(" + " ".join(hooks) + ")" + text[match.end():]
    mkinitcpio.write_text(text)

resume = f"resume=UUID={uuid}"
if bootloader == "grub":
    grub = Path("/etc/default/grub")
    text = grub.read_text()
    if resume not in text:
        match = re.search(
            r'^(GRUB_CMDLINE_LINUX_DEFAULT=)([\"\'])(.*)\2$',
            text,
            flags=re.M,
        )
        if match is None:
            raise SystemExit("Could not find GRUB_CMDLINE_LINUX_DEFAULT in /etc/default/grub")
        replacement = f'{match.group(1)}{match.group(2)}{resume} {match.group(3)}{match.group(2)}'
        text = text[:match.start()] + replacement + text[match.end():]
        grub.write_text(text)
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
PY

mkinitcpio -P
if [[ "$bootloader" == "grub" ]]; then
    grub-mkconfig -o /boot/grub/grub.cfg
fi
echo "Hibernate resume enabled using $swap_device (UUID: $swap_uuid)."
