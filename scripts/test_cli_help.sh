#!/usr/bin/env bash
set -euo pipefail

root_dir="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
cli="$root_dir/scripts/ugs.sh"

help_output="$($cli --help)"
printf '%s\n' "$help_output" | grep -Fqx 'usage: scripts/ugs.sh <command> [options]'
printf '%s\n' "$help_output" | grep -Fq 'migrate    preview or apply a complete offline package migration'
printf '%s\n' "$help_output" | grep -Fq 'branch close'
printf '%s\n' "$help_output" | grep -Fq 'docs/git/ugs-cli.md'

test "$("$cli" help | sha256sum | cut -d' ' -f1)" = "$(printf '%s\n' "$help_output" | sha256sum | cut -d' ' -f1)"
"$cli" init --help | grep -Fq 'initialize a UGS-governed repository'
"$cli" migrate --help | grep -Fq 'usage: ugs_upgrade.py migrate'
"$cli" migrate --help | grep -Fq -- '--dry-run'
"$cli" branch close --help | grep -Fq 'usage: ugs branch close'

echo "UGS CLI help fixtures passed"
