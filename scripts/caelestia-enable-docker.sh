#!/usr/bin/env bash

# Enable Docker and allow the regular user to access its socket.

set -euo pipefail

if [[ $EUID -eq 0 ]]; then
    echo "Run this script as your regular user; it invokes sudo when needed." >&2
    exit 1
fi

sudo usermod -aG docker "$(id -un)"
sudo systemctl enable --now docker.service

echo "Docker enabled. Log out and back in for the docker group membership to apply."
