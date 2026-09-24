#!/usr/bin/env python3
"""Independent UGS conformance implementation with stable error codes."""
import hashlib
import json
import os
import re
import sys
from pathlib import Path

OID = re.compile(r"^[0-9a-f]{40}$")
PASS_CODE = "UGS-0000"
CR_SECTIONS = ("Summary", "Motivation", "Test Evidence", "Risk", "Rollback", "Breaking Change", "Backport Target")
CR_V1_FIELDS = ("Format", "Schema Version", "Base", "Head or Range", "Integration Target", "Integration Strategy", "Review Evidence", "Title", "Revision", "Status", "Decision", "Policy Version", "Base OID", "Head OID", "Integrated Result", "Coverage OIDs", "Extensions")
CR_V1_FORMAT = "ugs-cr/v1"
CR_LEGACY_FORMAT = "ugs-cr/legacy-v0"
CR_BINDING_FORMAT = "ugs-cr-binding/v1"
CR_SCHEMA = "schema/cr.schema.json"
CR_TARGET = re.compile(r"^[A-Za-z0-9][A-Za-z0-9._/-]*$")
CR_POLICY_VERSION = re.compile(r"^v(0\.2|0\.3(-[0-9]+|-(draft-[0-9]+|rc-[0-9]+))?)$")


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


class CRProjectionError(ValueError):
    """A stable CR-model failure for consumers of cr_projection."""

    def __init__(self, code, message):
        super().__init__(message)
        self.code = code
        self.message = message


def canonical_json(value):
    """Return the compact, sorted UTF-8 JSON representation used for bindings."""
    return json.dumps(value, ensure_ascii=False, separators=(",", ":"), sort_keys=True)


def reject_nonstandard_json(value):
    raise ValueError("non-standard JSON constant: " + value)


def _cr_section_matches(text):
    alternatives = "|".join(re.escape(section) for section in CR_SECTIONS)
    return list(re.finditer(r"^## (" + alternatives + r")\n", text, re.MULTILINE))


def _cr_metadata(block, strict):
    fields = {}
    for line in block.splitlines():
        if not line:
            if strict:
                return None, fail("v1 metadata must not contain blank lines", "UGS-CR-021")
            continue
        if ": " not in line:
            if strict:
                return None, fail("unknown v1 metadata line: " + line, "UGS-CR-018")
            continue
        key, value = line.split(": ", 1)
        if key not in CR_V1_FIELDS:
            if strict:
                return None, fail("unknown v1 metadata field: " + key, "UGS-CR-018")
            continue
        if key in fields:
            return None, fail("duplicate metadata field: " + key, "UGS-CR-016")
        fields[key] = value
    return fields, None


def _cr_sections(text, start, strict):
    suffix = text[start:]
    matches = _cr_section_matches(suffix)
    if not matches:
        return None, fail("missing section: ## Summary", "UGS-CR-005")
    if strict:
        for heading in re.findall(r"^## (.+)$", suffix, re.MULTILINE):
            if heading not in CR_SECTIONS:
                return None, fail("unknown v1 section: ## " + heading, "UGS-CR-020")
    counts = {section: 0 for section in CR_SECTIONS}
    for match in matches:
        counts[match.group(1)] += 1
    for section in CR_SECTIONS:
        if not counts[section]:
            return None, fail("missing section: ## " + section, "UGS-CR-005")
        if counts[section] > 1:
            return None, fail("duplicate section: ## " + section, "UGS-CR-020")
    headings = tuple(match.group(1) for match in matches)
    if strict and headings != CR_SECTIONS:
        return None, fail("v1 sections must use the canonical order", "UGS-CR-020")

    sections = {}
    for index, match in enumerate(matches):
        heading = match.group(1)
        body_start = match.end()
        if body_start >= len(suffix) or suffix[body_start] != "\n":
            return None, fail("section must have one blank line after heading: ## " + heading, "UGS-CR-021")
        body_start += 1
        if index + 1 < len(matches):
            block = suffix[body_start:matches[index + 1].start()]
            if not block.endswith("\n\n"):
                return None, fail("sections must be separated by one blank line", "UGS-CR-021")
            body = block[:-2]
        else:
            block = suffix[body_start:]
            if not block.endswith("\n"):
                return None, fail("record must end with LF", "UGS-CR-021")
            body = block[:-1]
        if not any(line.strip() and not re.fullmatch(r"<[^>]+>", line.strip()) for line in body.splitlines()):
            return None, fail("section must include non-placeholder content: ## " + heading, "UGS-CR-006")
        sections[heading] = body
    return sections, None


def _cr_binding(model):
    payload = {key: value for key, value in model.items() if key != "binding"}
    digest = hashlib.sha256(canonical_json(payload).encode("utf-8")).hexdigest()
    return {"format": CR_BINDING_FORMAT, "sha256": "sha256:" + digest}


def _render_cr_v1(model):
    integration = model["integration"]
    result = "pending" if integration["result_oid"] is None else integration["result_ref"] + "@" + integration["result_oid"]
    coverage = "none" if not model["coverage_oids"] else " ".join(model["coverage_oids"])
    values = {
        "Format": CR_V1_FORMAT,
        "Schema Version": "1",
        "Base": model["source"]["base_ref"],
        "Head or Range": model["source"]["head_or_range"],
        "Integration Target": integration["target_ref"],
        "Integration Strategy": integration["strategy"],
        "Review Evidence": integration["review_evidence"],
        "Title": model["title"],
        "Revision": str(model["revision"]),
        "Status": model["status"],
        "Decision": model["decision"],
        "Policy Version": model["policy_version"],
        "Base OID": model["source"]["base_oid"],
        "Head OID": model["source"]["head_oid"],
        "Integrated Result": result,
        "Coverage OIDs": coverage,
        "Extensions": canonical_json(model["extensions"]),
    }
    output = "# " + model["id"] + ": " + model["title"] + "\n\n"
    output += "\n".join(key + ": " + values[key] for key in CR_V1_FIELDS)
    output += "\n\n"
    for index, section in enumerate(CR_SECTIONS):
        output += "## " + section + "\n\n" + model["sections"][section]
        output += "\n" if index == len(CR_SECTIONS) - 1 else "\n\n"
    return output


def _cr_v1_projection(text):
    lines = text.splitlines()
    heading = re.fullmatch(r"# (CR-[0-9]{4}): (.+)", lines[0]) if lines else None
    if not heading:
        return None, fail("title must match # CR-XXXX: <title>", "UGS-CR-004")
    matches = _cr_section_matches(text)
    if not matches:
        return None, fail("missing section: ## Summary", "UGS-CR-005")
    preamble_start = len(lines[0]) + 1
    preamble = text[preamble_start:matches[0].start()]
    preliminary, error = _cr_metadata(preamble, strict=False)
    if error:
        return None, error
    if "Format" not in preliminary or preliminary.get("Format") != CR_V1_FORMAT:
        return None, fail("unsupported CR format", "UGS-CR-014")
    if "Schema Version" not in preliminary:
        return None, fail("unsupported CR schema version", "UGS-CR-015")
    if "\r" in text:
        return None, fail("v1 records must use LF line endings", "UGS-CR-021")
    if len(lines) < 2 or lines[1] != "":
        return None, fail("v1 title must be followed by one blank line", "UGS-CR-021")
    if not preamble.startswith("\n") or not preamble.endswith("\n\n"):
        return None, fail("v1 title must be followed by one blank line", "UGS-CR-021")
    fields, error = _cr_metadata(preamble[1:-2], strict=True)
    if error:
        return None, error
    sections, error = _cr_sections(text, matches[0].start(), strict=True)
    if error:
        return None, error

    for field in ("Base", "Head or Range", "Title", "Revision", "Status", "Decision", "Policy Version", "Base OID", "Head OID", "Integrated Result"):
        value = fields.get(field)
        if not value:
            return None, fail("missing " + field + ": line", "UGS-CR-002")
        if re.fullmatch(r"<[^>]+>", value):
            return None, fail(field + ": must not use an unfilled template placeholder", "UGS-CR-003")
    if not re.fullmatch(r"[1-9][0-9]*", fields["Revision"]):
        return None, fail("Revision must be a positive integer", "UGS-CR-017")
    if fields["Status"] not in {"pending", "accepted", "integrated", "rejected", "superseded"}:
        return None, fail("Status is invalid", "UGS-CR-017")
    if fields["Decision"] not in {"accepted", "rejected", "superseded", "pending"}:
        return None, fail("Decision is invalid", "UGS-CR-017")
    if not CR_POLICY_VERSION.fullmatch(fields["Policy Version"]):
        return None, fail("Policy Version is invalid", "UGS-CR-017")
    for field in ("Base OID", "Head OID"):
        if not OID.fullmatch(fields[field]):
            return None, fail("CR object IDs must be full lowercase SHA-1 values", "UGS-CR-007")

    missing = next((field for field in CR_V1_FIELDS if field not in fields), None)
    if missing:
        return None, fail("missing " + missing + ": line", "UGS-CR-002")
    if fields["Format"] != CR_V1_FORMAT:
        return None, fail("unsupported CR format", "UGS-CR-014")
    if fields["Schema Version"] != "1":
        return None, fail("unsupported CR schema version", "UGS-CR-015")
    if not CR_TARGET.fullmatch(fields["Integration Target"]):
        return None, fail("Integration Target is invalid", "UGS-CR-017")
    if fields["Integration Strategy"] not in {"rebase-ff", "merge", "squash"}:
        return None, fail("Integration Strategy is invalid", "UGS-CR-017")
    if fields["Review Evidence"] not in {"none", "trailers"}:
        return None, fail("Review Evidence is invalid", "UGS-CR-017")
    if heading.group(2) != fields["Title"]:
        return None, fail("title must match # CR-XXXX: <title>", "UGS-CR-004")
    try:
        extensions = json.loads(fields["Extensions"], parse_constant=reject_nonstandard_json)
    except (json.JSONDecodeError, ValueError) as exc:
        return None, fail("Extensions must be a JSON object: " + str(exc), "UGS-CR-019")
    if not isinstance(extensions, dict) or any(not isinstance(key, str) or not key.startswith("x-") for key in extensions):
        return None, fail("Extensions keys must begin with x-", "UGS-CR-019")

    coverage_value = fields["Coverage OIDs"]
    if coverage_value == "none":
        coverage = []
    else:
        if not coverage_value:
            return None, fail("Coverage OIDs is invalid", "UGS-CR-017")
        coverage = coverage_value.split()
        if any(not OID.fullmatch(item) for item in coverage):
            return None, fail("Coverage OIDs must contain full lowercase SHA-1 values", "UGS-CR-017")
        if len(set(coverage)) != len(coverage):
            return None, fail("Coverage OIDs must not contain duplicates", "UGS-CR-017")
        if coverage != sorted(coverage):
            return None, fail("Coverage OIDs must use lexical order", "UGS-CR-021")

    result = fields["Integrated Result"]
    if result == "pending":
        result_ref, result_oid = None, None
    else:
        result_match = re.fullmatch(r"([A-Za-z0-9][A-Za-z0-9._/-]*)@([0-9a-f]{40})", result)
        if not result_match or result_match.group(1) != fields["Integration Target"]:
            return None, fail("Integrated Result must match Integration Target and a full lowercase SHA-1", "UGS-CR-017")
        result_ref, result_oid = result_match.group(1), result_match.group(2)

    lifecycle = {
        "pending": ("pending", True),
        "accepted": ("accepted", True),
        "integrated": ("accepted", False),
        "rejected": ("rejected", True),
        "superseded": ("superseded", True),
    }
    expected_decision, expected_pending = lifecycle[fields["Status"]]
    if fields["Decision"] != expected_decision or (result_oid is None) != expected_pending:
        return None, fail("Status, Decision, and Integrated Result do not form a valid lifecycle state", "UGS-CR-022")

    model = {
        "$schema": CR_SCHEMA,
        "format": CR_V1_FORMAT,
        "schema_version": 1,
        "id": heading.group(1),
        "title": fields["Title"],
        "revision": int(fields["Revision"]),
        "status": fields["Status"],
        "decision": fields["Decision"],
        "policy_version": fields["Policy Version"],
        "source": {
            "base_ref": fields["Base"],
            "head_or_range": fields["Head or Range"],
            "base_oid": fields["Base OID"],
            "head_oid": fields["Head OID"],
        },
        "integration": {
            "strategy": fields["Integration Strategy"],
            "target_ref": fields["Integration Target"],
            "review_evidence": fields["Review Evidence"],
            "result_ref": result_ref,
            "result_oid": result_oid,
        },
        "coverage_oids": coverage,
        "sections": sections,
        "extensions": extensions,
    }
    model["binding"] = _cr_binding(model)
    if _render_cr_v1(model) != text:
        return None, fail("v1 record is not the canonical Markdown rendering", "UGS-CR-021")
    return model, None


def _cr_legacy_projection(text):
    """Parse the historical CR shape without applying v1 normalization."""
    lines = text.splitlines()
    heading = re.fullmatch(r"# (CR-[0-9]{4}): (.+)", lines[0]) if lines else None
    if not heading:
        return None, fail("title must match # CR-XXXX: <title>", "UGS-CR-004")
    matches = _cr_section_matches(text)
    if not matches:
        return None, fail("missing section: ## Summary", "UGS-CR-005")
    preamble_start = len(lines[0]) + 1
    preamble = text[preamble_start:matches[0].start()]
    fields, error = _cr_metadata(preamble, strict=False)
    if error:
        return None, error
    sections, error = _cr_sections(text, matches[0].start(), strict=False)
    if error:
        return None, error

    required = (
        "Base",
        "Head or Range",
        "Title",
        "Revision",
        "Status",
        "Decision",
        "Policy Version",
        "Base OID",
        "Head OID",
        "Integrated Result",
    )
    for field in required:
        value = fields.get(field)
        if not value:
            return None, fail("missing " + field + ": line", "UGS-CR-002")
        if re.fullmatch(r"<[^>]+>", value):
            return None, fail(field + ": must not use an unfilled template placeholder", "UGS-CR-003")
    if not re.fullmatch(r"[1-9][0-9]*", fields["Revision"]):
        return None, fail("Revision must be a positive integer", "UGS-CR-017")
    if fields["Status"] not in {"pending", "accepted", "integrated", "rejected", "superseded"}:
        return None, fail("Status is invalid", "UGS-CR-017")
    if fields["Decision"] not in {"accepted", "rejected", "superseded", "pending"}:
        return None, fail("Decision is invalid", "UGS-CR-017")
    if not CR_POLICY_VERSION.fullmatch(fields["Policy Version"]):
        return None, fail("Policy Version is invalid", "UGS-CR-017")
    for field in ("Base OID", "Head OID"):
        if not OID.fullmatch(fields[field]):
            return None, fail("CR object IDs must be full lowercase SHA-1 values", "UGS-CR-007")

    result = fields["Integrated Result"]
    if result != "pending" and not re.fullmatch(r"main@[0-9a-f]{40}", result):
        return None, fail("Integrated Result must match main@<full commit OID>", "UGS-CR-010")
    if fields["Status"] == "integrated" and result == "pending":
        return None, fail("integrated CRs must have a main@<full commit OID> result", "UGS-CR-009")

    strategy = fields.get("Integration Strategy")
    if strategy is not None and strategy not in {"rebase-ff", "merge", "squash"}:
        return None, fail("Integration Strategy is invalid", "UGS-CR-017")
    review_evidence = fields.get("Review Evidence")
    if review_evidence is not None and review_evidence != "trailers":
        return None, fail("Review Evidence is invalid", "UGS-CR-017")

    coverage_value = fields.get("Coverage OIDs")
    if coverage_value is None:
        coverage = []
    elif not coverage_value:
        return None, fail("Coverage OIDs is invalid", "UGS-CR-017")
    else:
        coverage = coverage_value.split()
        if any(not OID.fullmatch(item) for item in coverage):
            return None, fail("Coverage OIDs must contain full lowercase SHA-1 values", "UGS-CR-017")
        if len(set(coverage)) != len(coverage):
            return None, fail("Coverage OIDs must not contain duplicates", "UGS-CR-017")

    result_ref = None if result == "pending" else "main"
    result_oid = None if result == "pending" else result.removeprefix("main@")
    model = {
        "$schema": CR_SCHEMA,
        "format": CR_LEGACY_FORMAT,
        "schema_version": 0,
        "id": heading.group(1),
        "title": fields["Title"],
        "revision": int(fields["Revision"]),
        "status": fields["Status"],
        "decision": fields["Decision"],
        "policy_version": fields["Policy Version"],
        "source": {
            "base_ref": fields["Base"],
            "head_or_range": fields["Head or Range"],
            "base_oid": fields["Base OID"],
            "head_oid": fields["Head OID"],
        },
        "integration": {
            "strategy": strategy,
            "target_ref": "main",
            "review_evidence": review_evidence,
            "result_ref": result_ref,
            "result_oid": result_oid,
        },
        "coverage_oids": coverage,
        "sections": sections,
        "extensions": {},
    }
    model["binding"] = _cr_binding(model)
    return model, None


def cr_projection(text):
    """Return a CR projection or raise CRProjectionError.

    The returned object has the same sorted-JSON representation as the
    scripts/cr_model.py --json command for valid v1 and legacy inputs. This is
    intentionally independent of the reference parser so conformance tests
    can compare the two implementations.
    """
    model, error = (_cr_v1_projection(text) if _cr_has_v1_metadata(text) else _cr_legacy_projection(text))
    if error:
        raise CRProjectionError(error[2], error[1])
    return model


def cr_projection_json(text):
    """Return cr_projection using the reference CLI's stable JSON layout."""
    return json.dumps(cr_projection(text), ensure_ascii=False, indent=2, sort_keys=True) + "\n"


def _cr_v1(text):
    _, error = _cr_v1_projection(text)
    return error if error else passed()


def _cr_has_v1_metadata(text):
    matches = _cr_section_matches(text)
    if not matches:
        return False
    first_line_end = text.find("\n")
    if first_line_end < 0:
        return False
    preamble = text[first_line_end + 1:matches[0].start()]
    return any(line.startswith("Format: ") or line.startswith("Schema Version: ") for line in preamble.splitlines())


def cr(text):
    if _cr_has_v1_metadata(text):
        return _cr_v1(text)
    _, error = _cr_legacy_projection(text)
    return error if error else passed()


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
    if len(sys.argv) == 3 and sys.argv[1] == "--cr-json":
        try:
            text = Path(sys.argv[2]).read_bytes().decode("utf-8")
            sys.stdout.write(cr_projection_json(text))
            return 0
        except (OSError, UnicodeDecodeError) as exc:
            message = str(exc)
            if os.environ.get("UGS_ERROR_FORMAT") == "json":
                print(json.dumps({"format": "ugs-error/v1", "code": "UGS-CONFORMANCE-002", "message": message}, sort_keys=True), file=sys.stderr)
            else:
                print("UGS-CONFORMANCE-002: " + message, file=sys.stderr)
            return 1
        except CRProjectionError as exc:
            if os.environ.get("UGS_ERROR_FORMAT") == "json":
                print(json.dumps({"format": "ugs-error/v1", "code": exc.code, "message": exc.message}, ensure_ascii=False, sort_keys=True), file=sys.stderr)
            else:
                print(exc.code + ": " + exc.message, file=sys.stderr)
            return 1
    if len(sys.argv) > 1:
        print("usage: conformance.py [--cr-json <cr-record>]", file=sys.stderr)
        return 2
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
