#!/usr/bin/env bash
set -euo pipefail
if [ "$#" -ne 2 ]; then echo "usage: $0 <release-tag> <download-dir>" >&2; exit 2; fi
tag="$1"
download_dir="$2"
mkdir -p "$download_dir"
gh release download "$tag" \
  --pattern "ugs-bootstrap-${tag}.tar.gz" \
  --pattern "ugs-bootstrap-${tag}.tar.gz.sha256" \
  --pattern "ugs-bootstrap-${tag}.tar.gz.manifest.json" \
  --dir "$download_dir"
