#!/usr/bin/env python3
"""Small, dependency-free UGS conformance implementation.

This intentionally does not source or execute the Bash validators.  It is a
second implementation used to detect drift in the reference scripts.
"""
import json
import re
import sys
from pathlib import Path

OID = re.compile(r"^[0-9a-f]{40}$")

def fail(reason):
    return ("fail", reason)

def policy(value):
    if not isinstance(value, dict): return fail("top level must be an object")
    allowed = {"$schema", "format", "schema_version", "policy_version", "conformance_level", "migration", "branching", "commits", "review", "automation", "releases", "exceptions", "quality", "supply_chain", "repository_shape", "extensions"}
    unknown = set(value) - allowed
    if unknown: return fail("unknown top-level field")
    if value.get("$schema") != "schema/policy.schema.json": return fail("unsupported $schema")
    if value.get("format") != "ugs-policy/v0.3": return fail("unsupported format")
    if value.get("schema_version") != 1: return fail("unsupported schema_version")
    if value.get("policy_version") != "0.3": return fail("unsupported policy_version")
    if value.get("conformance_level") not in {"baseline", "standard", "high-trust"}: return fail("invalid conformance_level")
    for key in ("migration", "branching", "commits", "review", "automation", "releases", "exceptions", "extensions"):
        if not isinstance(value.get(key), dict): return fail("missing or invalid " + key)
    if value["extensions"] and any(not str(k).startswith("x-") for k in value["extensions"]): return fail("extensions keys must begin with x-")
    return ("pass", "")

def review(text):
    if not re.search(r"^Reviewed-by: .+$", text, re.M): return fail("Reviewed-by")
    if not re.search(r"^Tested-by: .+$", text, re.M): return fail("Tested-by")
    return ("pass", "")

def evidence(value, kind):
    if not isinstance(value, dict): return fail("invalid JSON")
    if kind == "build":
        checks = [(value.get("schema_version") == 1 and value.get("type") == "ugs-build-record", "invalid build record header"), (bool(re.fullmatch(r"v\d+\.\d+\.\d+", str(value.get("release_tag", "")))), "invalid release tag"), (bool(OID.fullmatch(str(value.get("commit", "")))), "invalid commit SHA"), (bool(re.fullmatch(r"sha256:[0-9a-f]{64}", str(value.get("artifact", {}).get("digest", "")))), "invalid artifact digest"), (bool(value.get("builder", {}).get("id")), "builder identity is missing")]
    else:
        checks = [(value.get("schema_version") == 1 and value.get("type") == "ugs-release-attestation", "invalid attestation header"), (bool(re.fullmatch(r"v\d+\.\d+\.\d+", str(value.get("release_tag", "")))), "invalid release tag"), (bool(OID.fullmatch(str(value.get("commit", "")))), "invalid commit SHA"), (bool(re.fullmatch(r"sha256:[0-9a-f]{64}", str(value.get("artifact", {}).get("digest", "")))), "invalid artifact digest"), (bool(value.get("builder", {}).get("id")), "builder identity is missing")]
    for ok, reason in checks:
        if not ok: return fail(reason)
    return ("pass", "")

def sbom(value):
    if not isinstance(value, dict): return fail("invalid JSON")
    if value.get("spdxVersion"):
        if not str(value["spdxVersion"]).startswith("SPDX-"): return fail("invalid SPDX version")
        packages = value.get("packages")
        if not isinstance(packages, list) or not packages or any(not p.get("name") or not p.get("versionInfo") or not (p.get("SPDXID") or p.get("checksums")) for p in packages):
            return fail("SPDX packages lack name, version, and identity")
        metadata = value.get("documentComment", "")
    elif value.get("bomFormat") == "CycloneDX":
        if not value.get("specVersion") or not value.get("metadata", {}).get("timestamp"): return fail("CycloneDX metadata is incomplete")
        components = value.get("components")
        if not isinstance(components, list) or not components or any(not p.get("name") or not p.get("version") or not (p.get("bom-ref") or p.get("hashes")) for p in components):
            return fail("CycloneDX components lack name, version, and identity")
        metadata = ";".join(str(p.get("name")) + "=" + str(p.get("value")) for p in value.get("metadata", {}).get("properties", []) if p.get("name") in {"ugs:sourceCommit", "ugs:release", "ugs:artifactDigest"})
    else: return fail("unsupported SBOM format; use SPDX or CycloneDX")
    for key, pattern, reason in (("ugs:sourceCommit", r"[0-9a-f]{40}", "UGS source commit metadata is missing"), ("ugs:release", r"v\d+\.\d+\.\d+", "UGS release metadata is missing"), ("ugs:artifactDigest", r"sha256:[0-9a-f]{64}", "UGS artifact digest metadata is missing")):
        if not re.search(re.escape(key) + r"=" + pattern, metadata): return fail(reason)
    return ("pass", "")

def cr(text, git_check=False):
    if not re.search(r"^# CR-\d{4}: .+$", text, re.M): return fail("title")
    fields = {m.group(1): m.group(2) for m in re.finditer(r"^([^\n:]+): (.+)$", text, re.M)}
    for field in ("Base", "Head or Range", "Title", "Revision", "Status", "Decision", "Policy Version", "Base OID", "Head OID", "Integrated Result"):
        if not fields.get(field): return fail("missing " + field)
    for heading in ("Summary", "Motivation", "Test Evidence", "Risk", "Rollback", "Breaking Change", "Backport Target"):
        section = re.search(r"^## " + re.escape(heading) + r"\n(.*?)(?=^## |\Z)", text, re.M | re.S)
        if not section or not re.search(r"\S", section.group(1)): return fail("missing section: " + heading)
    return ("pass", "")

def run(root, item):
    path = root / item["path"]
    try:
        if item["kind"] in {"policy", "sbom", "build", "attestation"}:
            value = json.loads(path.read_text())
            if item["kind"] == "policy": result = policy(value)
            elif item["kind"] == "sbom": result = sbom(value)
            else: result = evidence(value, item["kind"])
        elif item["kind"] == "review": result = review(path.read_text())
        else: result = cr(path.read_text())
    except (OSError, ValueError) as exc:
        result = fail(str(exc))
    expected = item["expected"]
    if result[0] != expected: return fail("expected %s, got %s (%s)" % (expected, result[0], result[1]))
    if expected == "fail" and item.get("reason") not in result[1]: return fail("expected reason %r, got %r" % (item["reason"], result[1]))
    return result

def main():
    root = Path(__file__).resolve().parent.parent
    catalog = json.loads((root / "tests/conformance/manifest.json").read_text())
    failures = []
    for item in catalog["fixtures"]:
        result = run(root, item)
        print(json.dumps({"id": item["id"], "status": result[0], "reason": result[1]}, sort_keys=True))
        if result[0] == "fail" and not (item["expected"] == "fail" and item.get("reason") in result[1]): failures.append(item["id"])
    if failures: return 1
    return 0

if __name__ == "__main__": sys.exit(main())
