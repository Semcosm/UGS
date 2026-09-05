#!/usr/bin/env bash
set -euo pipefail
repo_root="$(git rev-parse --show-toplevel)"
exec "$repo_root/adapters/github/create_pr_from_cr.sh" "$@"
