#!/usr/bin/env python3
"""Validate a configured tree against a Markdown Document Map."""
import json
import re
import sys
from pathlib import Path

LINK = re.compile(r"^(?P<indent> *)- \[(?P<title>[^]]+)\]\((?P<path>[^)]+)\)\s*$")
GROUP = re.compile(r"^(?P<indent> *)- \*\*(?P<title>[^*]+)\*\*\s*$")


def fail(message):
    print(f"document map validation failed: {message}", file=sys.stderr)
    return 1


def flatten(nodes, depth=0, output=None):
    output = [] if output is None else output
    for node in nodes:
        output.append((depth, node["title"], node.get("path")))
        flatten(node.get("children", []), depth + 1, output)
    return output


def validate_nodes(nodes, seen_titles, seen_paths):
    if not isinstance(nodes, list) or not nodes:
        return "nodes must be a non-empty array"
    for node in nodes:
        if not isinstance(node, dict) or not isinstance(node.get("title"), str) or not node["title"].strip():
            return "each node must have a non-empty title"
        title = node["title"]
        if title in seen_titles:
            return "node titles must be unique"
        seen_titles.add(title)
        path = node.get("path")
        children = node.get("children")
        if path is None and not children:
            return f"node has neither path nor children: {title}"
        if path is not None:
            if not isinstance(path, str) or not path or Path(path).is_absolute() or ".." in Path(path).parts:
                return f"node path is not repository-relative: {path}"
            if path in seen_paths:
                return "node paths must be unique"
            seen_paths.add(path)
        if children is not None:
            error = validate_nodes(children, seen_titles, seen_paths)
            if error:
                return error
    return None


def main():
    root = Path(__file__).resolve().parent.parent
    config_path = Path(sys.argv[1]) if len(sys.argv) > 1 else root / ".ugs/document-map.json"
    if not config_path.is_absolute():
        config_path = root / config_path
    try:
        config = json.loads(config_path.read_text())
    except (OSError, json.JSONDecodeError) as exc:
        return fail(f"cannot read configuration: {exc}")
    if config.get("$schema") != "schema/document-map.schema.json" or config.get("format") != "ugs-document-map/v1" or config.get("schema_version") != 1:
        return fail("unsupported configuration header")
    error = validate_nodes(config.get("nodes"), set(), set())
    if error:
        return fail(error)
    document = root / config.get("document", "")
    if not document.is_file():
        return fail(f"mapped document does not exist: {config.get('document')}")
    entries = flatten(config["nodes"])
    titles = [title for _, title, _ in entries]
    paths = [path for _, _, path in entries if path]
    for _, title, path in entries:
        if not isinstance(title, str) or not title.strip():
            return fail("node titles must be non-empty strings")
        if path:
            candidate = root / path
            if not candidate.is_file():
                return fail(f"mapped path does not exist: {path}")
    text = document.read_text()
    heading = re.escape(config["heading"])
    match = re.search(r"^##[ \t]+" + heading + r"[ \t]*$", text, re.MULTILINE)
    if not match:
        return fail(f"heading not found in {config['document']}: {config['heading']}")
    end = re.search(r"^##[ \t]+", text[match.end():], re.MULTILINE)
    section = text[match.end(): match.end() + end.start() if end else len(text)]
    actual = []
    for line in section.splitlines():
        parsed = LINK.match(line) or GROUP.match(line)
        if parsed:
            path = parsed.groupdict().get("path")
            actual.append((len(parsed.group("indent")) // 2, parsed.group("title"), path))
    if actual != entries:
        return fail("README entries do not exactly match configured tree (title, path, or two-space indentation differs)")
    print(f"document map validation passed ({config_path})")
    return 0


if __name__ == "__main__":
    sys.exit(main())
