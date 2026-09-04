#!/usr/bin/env bash
set -euo pipefail

root_dir="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
validator="$root_dir/scripts/validate_release_tag.sh"

"$validator" v0.2.0
"$validator" v0.3.0

if "$validator" v0.2 >/dev/null 2>&1; then
  echo "release tag fixture unexpectedly passed: invalid version" >&2
  exit 1
fi
