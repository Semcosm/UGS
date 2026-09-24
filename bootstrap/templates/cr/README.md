# Change Requests

Record accepted changes under `cr/` using the UGS CR template.

New portable records use `ugs-cr/v1`: the Markdown file is the authoritative
record, its metadata and seven sections have a fixed canonical order, and the
reference parser emits a deterministic `binding.sha256`. Use
`scripts/cr_model.py` with `.ugs/schema/cr.schema.json` to inspect or validate
the canonical projection.

Records without `Format: ugs-cr/v1` remain `ugs-cr/legacy-v0` historical
evidence. Do not rewrite an accepted record merely to add v1 metadata.
`Coverage OIDs` is `none` when empty, or a lexically sorted, ASCII-space-
delimited list of distinct full lowercase SHA-1 OIDs.

The `scripts/create_pr_from_cr.sh` and `scripts/validate_pr_cr.sh` commands are compatibility wrappers for the optional GitHub adapter. In the baseline profile they report that the adapter is not installed; initialize or migrate with `--profile standard` or `--profile high-trust` to enable them.
