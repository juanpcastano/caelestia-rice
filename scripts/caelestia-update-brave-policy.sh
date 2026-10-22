#!/bin/bash
set -euo pipefail

state_home=${XDG_STATE_HOME:-$HOME/.local/state}
scheme_file="$state_home/caelestia/scheme.json"

surface=$(python3 - "$scheme_file" <<'PY'
import json
import sys
from pathlib import Path

scheme = json.loads(Path(sys.argv[1]).read_text(encoding="utf-8"))
print(scheme["colours"]["surface"])
PY
)

printf '%s\n' "$surface" |
    sudo -n /usr/local/libexec/caelestia-brave-policy

# Chromium/Brave receives the policy refresh through its existing browser
# process. It is harmless if Brave is not running or rejects the request.
brave --refresh-platform-policy --no-startup-window >/dev/null 2>&1 || true
