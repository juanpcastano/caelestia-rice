#!/usr/bin/env bash
set -u

# Mount data filesystems that UDev marked as UDisks-auto eligible and that
# were already present before the user volume monitor started.
while read -r device type filesystem mountpoint _; do
    [[ "$type" == "part" && -n "$filesystem" && -z "$mountpoint" ]] || continue

    auto_mount=$(udevadm info --query=property --name="$device" 2>/dev/null \
        | awk -F= '$1 == "UDISKS_AUTO" { print $2; exit }')
    [[ "$auto_mount" == "1" ]] || continue

    udisksctl mount --block-device "$device" --no-user-interaction \
        >/dev/null 2>&1 || true
done < <(lsblk --noheadings --raw --paths --output NAME,TYPE,FSTYPE,MOUNTPOINT)
