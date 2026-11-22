# For setup.sh: the split fixture, which several cases share.
# A standard dish in idea: the interview is done and the brief gate is open. The brief has two done-checks in separate modules,
# and each needs two units and a public change, so each part would be a standard dish. PART2 swaps in another second part.
printf 'import urllib.request\n\ndef fetch(url):\n    return urllib.request.urlopen(url).read()\n' > client.py
printf 'from client import fetch\n\ndef sync(urls):\n    return [fetch(u) for u in urls]\n' > sync.py
printf 'def _fmt(total):\n    return "%%.2f" %% total\n\ndef rows(orders):\n    return [[o["id"], _fmt(o["total"])] for o in orders]\n' > report.py
printf 'import sys\n\ndef main(argv):\n    return 0\n\nif __name__ == "__main__":\n    sys.exit(main(sys.argv[1:]))\n' > cli.py
mkdir -p tests && printf 'from report import rows\n\ndef test_rows():\n    assert rows([{"id": 1, "total": 2}]) == [[1, "2.00"]]\n' > tests/test_report.py
printf '__pycache__/\n.pytest_cache/\n' >> .git/info/exclude
git add -A && git_q commit -qm init
slug="${SLUG:-sync-export}"; s=".cookbook/dishes/$slug"; mkdir -p "$s"
goal2="${GOAL2:-An operator can export the orders as CSV.}"
decisions2="${DECISIONS2:-- Export: \`report.rows\` gains an optional \`min_total\` argument; orders below it are left out.
- Export: a new \`export\` command in \`cli.py\` takes \`--min-total\` and a path, and writes the rows as CSV under the header \`id,total\`.
- Both parts use the standard library only.}"
check2="${CHECK2:-- \`python -m pytest tests/test_export.py\` passes: \`export --min-total 10 out.csv\` writes the header and only the orders of 10 or more.}"
cat > "$s/brief.md" <<B
# Brief: $slug
## Goal
The nightly sync survives a transient network error. $goal2
## Decisions
- Sync: \`fetch\` retries three times with a fixed one-second wait, then raises the last error.
- Sync: \`sync\` returns a result with a public \`failed\` list of the URLs that still failed; one bad URL no longer stops the run.
$decisions2
## Non-goals
Backoff, jitter, other export formats.
## Done-checks
- \`python -m pytest tests/test_sync.py\` passes: a URL that fails twice and then answers is returned, and a URL that always fails lands in \`failed\`.
$check2
## Contested shape: no
## Open facts
None.
B
cat > "$s/ledger.md" <<L
# $slug
ask: ${ASK:-make the nightly sync survive network errors and add a CSV export of orders}
meal: none
phase: idea
size: standard, done-check clear, several units, reach two modules, no risk, shape settled
size changes:
overlays: missing
gates: brief open, recipe open

| unit | check | parallel | status | fails | evidence |
|---|---|---|---|---|---|

events:
- 2026-11-10 interview done: no decision open, no research pending; brief written, gate not yet shown
L
