#!/usr/bin/env bash
set -euo pipefail
root_dir="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"

case "${1:-}" in
  init)
    shift
    exec "$root_dir/scripts/ugs_init.sh" "$@"
    ;;
  branch)
    shift
    if [ "${1:-}" != "close" ]; then
      echo "usage: $0 branch close <branch> [options]" >&2
      exit 2
    fi
    shift
    exec python3 "$root_dir/scripts/branch_close.py" "$@"
    ;;
  install|upgrade|migrate|activate|rollback)
    exec python3 "$root_dir/scripts/ugs_upgrade.py" "$@"
    ;;
  *)
    echo "usage: $0 {init|branch|install|upgrade|migrate|activate|rollback} [options]" >&2
    exit 2
    ;;
esac
