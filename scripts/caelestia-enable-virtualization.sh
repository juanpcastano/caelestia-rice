#!/usr/bin/env bash

# Enable the libvirt socket and configure the default NAT network.

set -euo pipefail

if [[ $EUID -eq 0 ]]; then
    echo "Run this script as your regular user; it invokes sudo when needed." >&2
    exit 1
fi

sudo systemctl enable --now libvirtd.socket
sudo usermod -aG libvirt "$(id -un)"

if sudo virsh net-info default >/dev/null 2>&1; then
    sudo virsh net-autostart default >/dev/null
    sudo virsh net-start default >/dev/null 2>&1 || true
else
    echo "The libvirt default network was not found; configure networking in virt-manager."
fi

echo "Virtualization enabled. Log out and back in for the libvirt group membership to apply."
