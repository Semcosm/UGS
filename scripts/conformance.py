#!/usr/bin/env python3
"""Independent UGS conformance implementation with stable error codes."""
import json
import re
import sys
from pathlib import Path

OID = re.compile(r"^[0-9a-f]{40}$")
PASS_CODE = "UGS-0000"


def passed():
    return ("pass", "", PASS_CODE)


def fail(reason, code):
    return ("fail", reason, code)


def policy(value):
    if not isinstance(value, dict):
        return fail("top level must be an object", "UGS-POLICY-004")
    allowed = {"$schema", "format", "schema_version", "policy_version", "conformance_level", "migration", "branching", "commits", "review", "automation", "releases", "exceptions", "quality", "supply_chain", "repository_shape", "extensions"}
    unknown = set(value) - allowed
    if unknown:
        return fail("unknown top-level field", "UGS-POLICY-005")
    if value.get("$schema") != "schema/policy.schema.json":
        return fail("unsupported $schema", "UGS-POLICY-006")
    if value.get("format") != "ugs-policy/v0.3":
        return fail("unsupported format", "UGS-POLICY-007")
    if value.get("schema_version") != 1:
        return fail("unsupported schema_version", "UGS-POLICY-008")
    if value.get("policy_version") != "0.3":
        return fail("unsupported policy_version", "UGS-POLICY-009")
    if value.get("conformance_level") not in {"baseline", "standard", "high-trust"}:
        return fail("invalid conformance_level", "UGS-POLICY-010")
    for key in ("migration", "branching", "commits", "review", "automation", "releases", "exceptions", "extensions"):
        if not isinstance(value.get(key), dict):
            return fail("missing or invalid " + key, "UGS-POLICY-999")
    if value["extensions"] and any(not str(k).startswith("x-") for k in value["extensions"]):
        return fail("extensions keys must begin with x-", "UGS-POLICY-011")
    return passed()


def review(text):
    if not re.search(r"^Reviewed-by: .+$", text, re.M):
        return fail("Reviewed-by", "UGS-REVIEW-002")
    if not re.search(r"^Tested-by: .+$", text, re.M):
        return fail("Tested-by", "UGS-REVIEW-003")
    return passed()


def evidence(value, kind):
    if not isinstance(value, dict):
        return fail("invalid JSON", "UGS-%s-003" % ("BUILD" if kind == "build" else "ATTEST"))
    prefix = "BUILD" if kind == "build" else "ATTEST"
    header_type = "ugs-build-record" if kind == "build" else "ugs-release-attestation"
    checks = [
        (value.get("schema_version") == 1 and value.get("type") == header_type, "invalid build record header" if kind == "build" else "invalid attestation header", "004"),
        (bool(re.fullmatch(r"v\d+\.\d+\.\d+", str(value.get("release_tag", "")))), "invalid release tag", "005" if kind == "build" else "006"),
        (bool(OID.fullmatch(str(value.get("commit", "")))), "invalid commit SHA", "006" if kind == "build" else "007"),
        (bool(re.fullmatch(r"sha256:[0-9a-f]{64}", str(value.get("artifact", {}).get("digest", "")))), "invalid artifact digest", "007" if kind == "build" else "009"),
        (bool(value.get("builder", {}).get("id")), "builder identity is missing", "008" if kind == "build" else "010"),
        (bool(re.match(r"^\d{4}-\d{2}-\d{2}T", str(value.get("built_at", "")))), "build timestamp is missing", "009" if kind == "build" else "011"),
    ]
    for ok, reason, suffix in checks:
        if not ok:
            return fail(reason, "UGS-%s-%s" % (prefix, suffix))
    return passed()


def sbom(value):
    if not isinstance(value, dict):
        return fail("invalid JSON", "UGS-SBOM-003")
    if value.get("spdxVersion"):
        if not str(value["spdxVersion"]).startswith("SPDX-"):
            return fail("invalid SPDX version", "UGS-SBOM-004")
        if not re.match(r"^\d{4}-\d{2}-\d{2}T", str(value.get("creationInfo", {}).get("created", ""))):
            return fail("SPDX creation time is missing", "UGS-SBOM-005")
        packages = value.get("packages")
        if not isinstance(packages, list) or not packages or any(not p.get("name") or not p.get("versionInfo") or not (p.get("SPDXID") or p.get("checksums")) for p in packages):
            return fail("SPDX packages lack name, version, and identity", "UGS-SBOM-006")
        metadata = value.get("documentComment", "")
    elif value.get("bomFormat") == "CycloneDX":
        if not value.get("specVersion") or not re.match(r"^\d{4}-\d{2}-\d{2}T", str(value.get("metadata", {}).get("timestamp", ""))):
            return fail("CycloneDX metadata is incomplete", "UGS-SBOM-007")
        components = value.get("components")
        if not isinstance(components, list) or not components or any(not p.get("name") or not p.get("version") or not (p.get("bom-ref") or p.get("hashes")) for p in components):
            return fail("CycloneDX components lack name, version, and identity", "UGS-SBOM-008")
        metadata = ";".join(str(p.get("name")) + "=" + str(p.get("value")) for p in value.get("metadata", {}).get("properties", []) if p.get("name") in {"ugs:sourceCommit", "ugs:release", "ugs:artifactDigest"})
    else:
        return fail("unsupported SBOM format; use SPDX or CycloneDX", "UGS-SBOM-009")
    for key, pattern, reason, code in (
        ("ugs:sourceCommit", r"[0-9a-f]{40}", "UGS source commit metadata is missing", "UGS-SBOM-010"),
        ("ugs:release", r"v\d+\.\d+\.\d+", "UGS release metadata is missing", "UGS-SBOM-011"),
        ("ugs:artifactDigest", r"sha256:[0-9a-f]{64}", "UGS artifact digest metadata is missing", "UGS-SBOM-012"),
    ):
        if not re.search(re.escape(key) + r"=" + pattern, metadata):
            return fail(reason, code)
    return passed()


def cr(text):
    if not re.search(r"^# CR-\d{4}: .+$", text, re.M):
        return fail("title", "UGS-CR-004")
    fields = {m.group(1): m.group(2) for m in re.finditer(r"^([^\n:]+): (.+)$", text, re.M)}
    for field in ("Base", "Head or Range", "Title", "Revision", "Status", "Decision", "Policy Version", "Base OID", "Head OID", "Integrated Result"):
        if not fields.get(field):
            return fail("missing " + field, "UGS-CR-002")
    for heading in ("Summary", "Motivation", "Test Evidence", "Risk", "Rollback", "Breaking Change", "Backport Target"):
        section = re.search(r"^## " + re.escape(heading) + r"\n(.*?)(?=^## |\Z)", text, re.M | re.S)
        if not section or not re.search(r"\S", section.group(1)):
            return fail("missing section: " + heading, "UGS-CR-005")
    return passed()


def run(root, item):
    path = root / item["path"]
    try:
        if item["kind"] in {"policy", "sbom", "build", "attestation"}:
            value = json.loads(path.read_text())
            if item["kind"] == "policy":
                result = policy(value)
            elif item["kind"] == "sbom":
                result = sbom(value)
            else:
                result = evidence(value, item["kind"])
        elif item["kind"] == "review":
            result = review(path.read_text())
        else:
            result = cr(path.read_text())
    except (OSError, ValueError) as exc:
        result = fail(str(exc), "UGS-CONFORMANCE-002")
    expected = item["expected"]
    if result[0] != expected:
        return fail("expected %s, got %s (%s)" % (expected, result[0], result[1]), "UGS-CONFORMANCE-001")
    if expected == "fail" and item.get("reason") not in result[1]:
        return fail("expected reason %r, got %r" % (item["reason"], result[1]), "UGS-CONFORMANCE-001")
    if item.get("code") and item["code"] != result[2]:
        return fail("expected code %r, got %r" % (item["code"], result[2]), "UGS-CONFORMANCE-001")
    return result


def main():
    root = Path(__file__).resolve().parent.parent
    catalog = json.loads((root / "tests/conformance/manifest.json").read_text())
    failures = []
    for item in catalog["fixtures"]:
        result = run(root, item)
        print(json.dumps({"id": item["id"], "status": result[0], "code": result[2], "reason": result[1]}, sort_keys=True))
        if result[0] == "fail" and not (item["expected"] == "fail" and item.get("reason") in result[1] and item.get("code", result[2]) == result[2]):
            failures.append(item["id"])
    return 1 if failures else 0


if __name__ == "__main__":
    sys.exit(main())
