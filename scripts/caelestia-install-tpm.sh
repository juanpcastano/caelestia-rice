#!/usr/bin/env bash

set -euo pipefail

tpm_dir="$HOME/.tmux/plugins/tpm"

# TPM is installed separately from the tmux package. Keep this hook
# idempotent so `caelestia update` does not overwrite a user's plugins.
if [[ -f "$tpm_dir/tpm" ]]; then
    exit 0
fi

if [[ -e "$tpm_dir" ]]; then
    printf 'Cannot install TPM: %s exists but is not a complete TPM checkout.\n' "$tpm_dir" >&2
    exit 1
fi

mkdir -p "$(dirname "$tpm_dir")"
git clone --depth 1 https://github.com/tmux-plugins/tpm.git "$tpm_dir"
