#!/usr/bin/env python3
"""Build a deterministic, self-contained UGS bootstrap release asset."""
import argparse
import gzip
import hashlib
import json
import os
import shutil
import subprocess
import tarfile
import tempfile
from pathlib import Path

def digest(path):
    h = hashlib.sha256()
    h.update(path.read_bytes())
    return h.hexdigest()

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("version", help="release version, for example v0.3.17")
    parser.add_argument("--output-dir", default="dist")
    args = parser.parse_args()
    root = Path(__file__).resolve().parent.parent
    output = (root / args.output_dir).resolve()
    output.mkdir(parents=True, exist_ok=True)
    with tempfile.TemporaryDirectory(prefix="ugs-bootstrap-") as temporary:
        stage = Path(temporary) / ("ugs-bootstrap-" + args.version)
        (stage / "bootstrap/templates").mkdir(parents=True)
        (stage / "scripts").mkdir(parents=True)
        shutil.copy2(root / "scripts/ugs_init.py", stage / "scripts/ugs_init.py")
        shutil.copy2(root / "scripts/ugs_init.sh", stage / "scripts/ugs_init.sh")
        shutil.copy2(root / "scripts/validate_policy_manifest.sh", stage / "scripts/validate_policy_manifest.sh")
        shutil.copy2(root / "bootstrap/README.md", stage / "README.md")
        shutil.copy2(root / "bootstrap/templates/policy.json", stage / "bootstrap/templates/policy.json")
        shutil.copy2(root / ".ugs/schema/policy.schema.json", stage / "bootstrap/templates/policy.schema.json")
        for path in stage.rglob("*"):
            if path.is_file(): path.chmod(0o755 if path.name.endswith(".sh") or path.name.endswith(".py") else 0o644)
        files = sorted(p for p in stage.rglob("*") if p.is_file())
        commit = subprocess.check_output(["git", "-C", str(root), "rev-parse", "HEAD"], text=True).strip()
        manifest = {"format": "ugs-bootstrap/v1", "version": args.version, "source_commit": commit, "profile": "baseline", "files": [{"path": str(p.relative_to(stage)), "sha256": digest(p)} for p in files]}
        (stage / "MANIFEST.json").write_text(json.dumps(manifest, indent=2, sort_keys=True) + "\n")
        archive = output / ("ugs-bootstrap-" + args.version + ".tar.gz")
        epoch = os.environ.get("SOURCE_DATE_EPOCH", "0")
        with archive.open("wb") as output_handle:
            with gzip.GzipFile(fileobj=output_handle, mode="wb", mtime=int(epoch)) as gzip_handle:
                with tarfile.open(fileobj=gzip_handle, mode="w") as tar:
                    for path in sorted(stage.rglob("*")):
                        info = tar.gettarinfo(str(path), arcname=str(path.relative_to(stage.parent)))
                        info.uid = info.gid = 0; info.uname = info.gname = "root"; info.mtime = int(epoch)
                        if path.is_file():
                            with path.open("rb") as handle: tar.addfile(info, handle)
                        else: tar.addfile(info)
        archive_digest = digest(archive)
        (output / (archive.name + ".sha256")).write_text(archive_digest + "  " + archive.name + "\n")
        shutil.copy2(stage / "MANIFEST.json", output / (archive.name + ".manifest.json"))
        print(archive)

if __name__ == "__main__": main()
