# The split fixture, where the decision that binds both parts is marked ADR and its alternatives are an open fact.
export DECISIONS2='- Export: `report.rows` gains an optional `min_total` argument; orders below it are left out.
- Export: a new `export` command in `cli.py` takes `--min-total` and a path, and writes the rows as CSV under the header `id,total`.
- Both parts use the standard library only. ADR'
. "$(dirname "$0")/../split/setup.sh"
awk '$0 == "None." { print "- Standard library only, alternatives: the `requests` and `tenacity` packages. Reason for the choice: the tool is copied as plain files to hosts that have no package installer."; next } { print }' "$s/brief.md" > "$s/brief.md.new" && mv "$s/brief.md.new" "$s/brief.md"
grep -q 'no package installer' "$s/brief.md"
