#!/usr/bin/env python3
"""Build a deterministic, self-contained UGS bootstrap release asset."""
import argparse
import gzip
import hashlib
import json
import os
import shutil
import stat
import subprocess
import tarfile
import tempfile
from pathlib import Path

def digest(path):
    h = hashlib.sha256()
    h.update(path.read_bytes())
    return h.hexdigest()


def component_manifest(stage, version, source_commit):
    all_profiles = ["baseline", "standard", "high-trust"]
    entries = []

    def add(source, target, kind, component, profiles=all_profiles, ownership="ugs"):
        source_path = stage / source
        if not source_path.is_file():
            raise RuntimeError("component source was not copied: " + source)
        mode = "0755" if source_path.stat().st_mode & stat.S_IXUSR else "0644"
        entries.append({
            "component": component,
            "kind": kind,
            "mode": mode,
            "ownership": ownership,
            "profiles": list(profiles),
            "source": source,
            "target": target,
        })

    # Core runtime files are updated automatically. Project-owned documents and
    # trust/configuration files are added when absent but require an explicit
    # overwrite flag when they already differ.
    for name in (
        "scripts/ugs.sh",
        "scripts/ugs_upgrade.py",
        "scripts/ugs_upgrade.sh",
        "scripts/ugs_init.py",
        "scripts/ugs_init.sh",
        "scripts/validate_policy_manifest.sh",
        "scripts/validate_cr_record.sh",
        "scripts/validate_cr_review.sh",
        "scripts/validate_pr_cr.sh",
        "scripts/create_pr_from_cr.sh",
        "scripts/validate_main_cr_range.sh",
        "scripts/validate_ref_update.sh",
        "adapters/bare-git/update",
    ):
        add(name, name, "core", "core")
    add("bootstrap/templates/README.md", "README.md", "core", "core", ownership="project")
    add("bootstrap/templates/repository-policy.md", "REPOSITORY_POLICY.md", "core", "core", ownership="project")
    add("bootstrap/templates/githooks/README.md", ".githooks/README.md", "core", "core", ownership="project")
    add("bootstrap/templates/githooks/commit-msg", ".githooks/commit-msg", "core", "core", ownership="project")
    add("bootstrap/templates/cr/README.md", "cr/README.md", "core", "core", ownership="project")
    add("bootstrap/templates/cr/TEMPLATE.md", "cr/TEMPLATE.md", "core", "core", ownership="project")
    add("bootstrap/templates/policy.schema.json", ".ugs/schema/policy.schema.json", "template", "templates")
    add("bootstrap/templates/document-map.schema.json", ".ugs/schema/document-map.schema.json", "template", "templates")

    for name in (
        "adapters/github/validate_pr.sh",
        "adapters/github/create_pr_from_cr.sh",
        "adapters/github/validate_adapter.sh",
        "adapters/github/validate_action_pinning.sh",
        "adapters/github/download_release.sh",
        "adapters/github/publish_release.sh",
        "scripts/validate_quality_profile.sh",
        "scripts/validate_supply_chain_profile.sh",
        "scripts/validate_supply_chain_evidence.sh",
        "scripts/validate_action_pinning.sh",
        "scripts/validate_repository_shape.sh",
    ):
        add(name, name, "profile-specific", "standard", ["standard", "high-trust"])
    for name in ("scripts/generate_document_map.py", "scripts/validate_document_map.py"):
        add(name, name, "profile-specific", "document-map", ["standard", "high-trust"])
    add(".github/workflows/ugs-validate.yml", ".github/workflows/ugs-validate.yml", "profile-specific", "standard", ["standard", "high-trust"], ownership="project")
    for name in ("LICENSE", "SECURITY.md", "CODE_OF_CONDUCT.md", "SUPPORT.md", "RELEASE.md"):
        add("bootstrap/templates/" + name, name, "profile-specific", "standard", ["standard", "high-trust"], ownership="project")
    add("bootstrap/templates/supply-chain-README.md", ".ugs/supply-chain/README.md", "profile-specific", "standard", ["standard", "high-trust"])
    for name in ("LICENSE", "LICENSES/Apache-2.0.txt", "LICENSES/CC-BY-4.0.txt"):
        add(name, ".ugs/docs/" + name, "documentation", "licensing")

    for relative in (
        "keys/README.md",
        "keys/allowed_signers",
        "keys/revoked_signers",
        "keys/signer_roles.json",
    ):
        add(relative, relative, "profile-specific", "high-trust", ["high-trust"], ownership="project")
    add(".ugs/schema/signer-roles.schema.json", ".ugs/schema/signer-roles.schema.json", "profile-specific", "high-trust", ["high-trust"])
    for name in ("scripts/validate_signer_roles.sh", "scripts/validate_commit_signatures.sh", "scripts/validate_release_tag.sh", "scripts/validate_release_attestation.sh"):
        add(name, name, "profile-specific", "high-trust", ["high-trust"])

    for source in sorted(path.relative_to(stage).as_posix() for path in (stage / "bootstrap/templates").rglob("*") if path.is_file()):
        if any(entry["source"] == source for entry in entries):
            continue
        add(source, ".ugs/templates/" + source.removeprefix("bootstrap/templates/"), "template", "templates")

    for source in sorted(path.relative_to(stage).as_posix() for path in (stage / "docs/git").glob("*.md")):
        add(source, ".ugs/" + source, "documentation", "documentation")
    for source, target in (
        ("README.md", ".ugs/docs/bootstrap-README.md"),
        ("OFFLINE-QUICKSTART.md", ".ugs/docs/OFFLINE-QUICKSTART.md"),
        ("CONTRIBUTING.md", ".ugs/docs/CONTRIBUTING.md"),
        ("RELEASE.md", ".ugs/docs/RELEASE.md"),
    ):
        add(source, target, "documentation", "documentation")
    if (stage / "RELEASE-NOTES.md").is_file():
        add("RELEASE-NOTES.md", ".ugs/docs/RELEASE-NOTES.md", "documentation", "documentation")
    add("scripts/test_profile_conformance.sh", "scripts/test_profile_conformance.sh", "test", "tests")

    # Package metadata is intentionally not copied into the consumer worktree.
    # It remains available in the release archive for verification and tooling.
    entries.append({
        "component": "release-metadata",
        "kind": "release-only",
        "mode": "0644",
        "ownership": "ugs",
        "profiles": all_profiles,
        "source": "COMPONENTS.json",
        "target": None,
    })
    entries.append({
        "component": "release-metadata",
        "kind": "release-only",
        "mode": "0644",
        "ownership": "ugs",
        "profiles": all_profiles,
        "source": "MANIFEST.json",
        "target": None,
    })
    return {
        "format": "ugs-components/v1",
        "version": version,
        "source_commit": source_commit,
        "active_profile": "preserved-until-explicit-activation",
        "files": sorted(entries, key=lambda entry: entry["source"]),
    }

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
        (stage / "adapters/github").mkdir(parents=True)
        (stage / "adapters/bare-git").mkdir(parents=True)
        (stage / ".github/workflows").mkdir(parents=True)
        (stage / "docs/git").mkdir(parents=True)
        (stage / "LICENSES").mkdir(parents=True)
        shutil.copy2(root / "LICENSE", stage / "LICENSE")
        for name in ("Apache-2.0.txt", "CC-BY-4.0.txt"):
            shutil.copy2(root / "LICENSES" / name, stage / "LICENSES" / name)
        shutil.copy2(root / "scripts/ugs_init.py", stage / "scripts/ugs_init.py")
        shutil.copy2(root / "scripts/ugs_init.sh", stage / "scripts/ugs_init.sh")
        for name in ("ugs.sh", "ugs_upgrade.py", "ugs_upgrade.sh", "validate_policy_manifest.sh", "validate_cr_record.sh", "validate_cr_review.sh", "validate_pr_cr.sh", "create_pr_from_cr.sh", "validate_main_cr_range.sh", "validate_ref_update.sh", "test_profile_conformance.sh"):
            shutil.copy2(root / "scripts" / name, stage / "scripts" / name)
        for name in ("validate_pr.sh", "create_pr_from_cr.sh", "validate_adapter.sh", "validate_action_pinning.sh", "download_release.sh", "publish_release.sh"):
            shutil.copy2(root / "adapters/github" / name, stage / "adapters/github" / name)
        shutil.copy2(root / "adapters/bare-git/update", stage / "adapters/bare-git/update")
        shutil.copy2(root / "bootstrap/README.md", stage / "README.md")
        shutil.copy2(root / "bootstrap/OFFLINE-QUICKSTART.md", stage / "OFFLINE-QUICKSTART.md")
        shutil.copy2(root / "CONTRIBUTING.md", stage / "CONTRIBUTING.md")
        shutil.copy2(root / "RELEASE.md", stage / "RELEASE.md")
        release_notes = root / "releases" / (args.version + ".md")
        if release_notes.is_file():
            shutil.copy2(release_notes, stage / "RELEASE-NOTES.md")
        for source in sorted((root / "docs/git").glob("*.md")):
            shutil.copy2(source, stage / "docs/git" / source.name)
        for source in sorted((root / "bootstrap/templates").rglob("*")):
            if source.is_file():
                destination = stage / "bootstrap/templates" / source.relative_to(root / "bootstrap/templates")
                destination.parent.mkdir(parents=True, exist_ok=True)
                shutil.copy2(source, destination)
        shutil.copy2(root / ".ugs/schema/document-map.schema.json", stage / "bootstrap/templates/document-map.schema.json")
        shutil.copy2(root / "bootstrap/templates/standard-workflow.yml", stage / "bootstrap/templates/standard-workflow.yml")
        shutil.copy2(root / ".github/workflows/ugs-validate.yml", stage / ".github/workflows/ugs-validate.yml")
        shutil.copy2(root / ".ugs/schema/policy.schema.json", stage / "bootstrap/templates/policy.schema.json")
        for name in ("validate_quality_profile.sh", "validate_supply_chain_profile.sh", "validate_supply_chain_evidence.sh", "validate_action_pinning.sh", "validate_repository_shape.sh", "generate_document_map.py", "validate_document_map.py"):
            shutil.copy2(root / "scripts" / name, stage / "scripts" / name)
        for relative in ("keys/README.md", "keys/allowed_signers", "keys/revoked_signers", "keys/signer_roles.json", ".ugs/schema/signer-roles.schema.json"):
            destination = stage / relative
            destination.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(root / relative, destination)
        for name in ("validate_signer_roles.sh", "validate_commit_signatures.sh", "validate_release_tag.sh", "validate_release_attestation.sh"):
            shutil.copy2(root / "scripts" / name, stage / "scripts" / name)
        for path in stage.rglob("*"):
            if path.is_file():
                relative = str(path.relative_to(stage))
                executable = path.name.endswith(".sh") or path.name.endswith(".py") or path.name == "commit-msg" or relative.startswith("adapters/")
                path.chmod(0o755 if executable else 0o644)
        commit = subprocess.check_output(["git", "-C", str(root), "rev-parse", "HEAD"], text=True).strip()
        components = component_manifest(stage, args.version, commit)
        (stage / "COMPONENTS.json").write_text(json.dumps(components, indent=2, sort_keys=True) + "\n")
        files = sorted(p for p in stage.rglob("*") if p.is_file())
        manifest = {"format": "ugs-bootstrap/v1", "version": args.version, "source_commit": commit, "profiles": ["baseline", "standard", "high-trust"], "files": [{"path": str(p.relative_to(stage)), "sha256": digest(p)} for p in files]}
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
        shutil.copy2(stage / "COMPONENTS.json", output / (archive.name + ".components.json"))
        print(archive)

if __name__ == "__main__": main()
