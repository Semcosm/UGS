#!/usr/bin/env bash
set -euo pipefail
root_dir="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
exec python3 "$root_dir/scripts/build_bootstrap_package.py" "$@"
