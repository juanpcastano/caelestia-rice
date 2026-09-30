#!/usr/bin/env bash

# Enable resume from a disk-backed swap partition. This is intentionally an
# optional component because the swap device and bootloader are machine-specific.

set -euo pipefail

if [[ $EUID -ne 0 ]]; then
    echo "Run this script through sudo." >&2
    exit 1
fi

swap_device=""
while read -r device; do
    [[ -z "$device" || "$device" == /dev/zram* ]] && continue
    [[ -b "$device" ]] || continue
    swap_device="$device"
    break
done < <(swapon --show=NAME --noheadings)

if [[ -z "$swap_device" ]]; then
    echo "No disk-backed swap partition was found; hibernation was not configured." >&2
    exit 1
fi

swap_uuid=$(blkid -s UUID -o value "$swap_device")
if [[ -z "$swap_uuid" ]]; then
    echo "Could not determine the UUID of $swap_device." >&2
    exit 1
fi

timestamp=$(date +%Y%m%d-%H%M%S)
cp -a /etc/mkinitcpio.conf "/etc/mkinitcpio.conf.bak.$timestamp"
cp -a /etc/default/grub "/etc/default/grub.bak.$timestamp"

python - "$swap_uuid" <<'PY'
from pathlib import Path
import re
import sys

uuid = sys.argv[1]

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

grub = Path("/etc/default/grub")
text = grub.read_text()
resume = f"resume=UUID={uuid}"
if resume not in text:
    text, count = re.subn(
        r'^GRUB_CMDLINE_LINUX_DEFAULT="',
        f'GRUB_CMDLINE_LINUX_DEFAULT="{resume} ',
        text,
        count=1,
        flags=re.M,
    )
    if count != 1:
        raise SystemExit("Could not find GRUB_CMDLINE_LINUX_DEFAULT in /etc/default/grub")
    grub.write_text(text)
PY

mkinitcpio -P
grub-mkconfig -o /boot/grub/grub.cfg
echo "Hibernate resume enabled using $swap_device (UUID: $swap_uuid)."
