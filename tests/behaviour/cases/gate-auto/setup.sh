# A standard dish at the recipe gate: brief approved, gate open; the recipe came from one sketch and keeps to the brief.
# The dish was handed off after the brief gate: the ledger names the dish worktree, and the session starts there (the `cwd` file).
wt="$(cd "$W" && pwd -P)/wt/fetch-retry"
printf 'import urllib.request\n\ndef fetch(url):\n    return urllib.request.urlopen(url).read()\n' > client.py
printf 'from client import fetch\n\ndef load(url):\n    return fetch(url)\n' > app.py
git add -A && git_q commit -qm init
s=.cookbook/dishes/fetch-retry; mkdir -p "$s"
cat > "$s/brief.md" <<'B'
# Brief: fetch-retry
Problem: fetch() fails on a transient network error.
Decision: three tries in all, with a fixed one-second wait between tries.
Done-check: `python -m pytest tests/test_client.py` passes with a test where the first two calls raise URLError.
B
cat > "$s/recipe.md" <<'R'
# Recipe: fetch-retry
## Problem
fetch() fails on a transient network error.
## Usage
`fetch(url)` keeps its signature and retries inside.
## Shape
A loop inside `fetch`: three tries in all, a one-second wait between tries, re-raise the last URLError.
## Units
| id | change | check | depends on | parallel |
|---|---|---|---|---|
| retry | add the retry loop to fetch and a test for it | `python -m pytest tests/test_client.py` passes | none | no |
## Taste
- surface: the fetch function
- judgement checks: none
- mutating checks: none
## Out of scope
Backoff, jitter.
## Choice
One sketch; standard dish.
R
cat > "$s/ledger.md" <<L
# fetch-retry
ask: add retry to the fetch client
meal: none
worktree: $wt
phase: recipe
size: standard, done-check clear, one unit, no reach, no risk, shape open
size changes:
overlays: missing
gates: brief 2026-11-10, recipe open

| unit | check | parallel | status | fails | evidence |
|---|---|---|---|---|---|

events:
- 2026-11-10 brief approved; handed off to $wt
L
git worktree add -q -b fetch-retry "$wt"
