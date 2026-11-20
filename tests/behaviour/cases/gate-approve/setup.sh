# A standard dish at the recipe gate: brief approved, recipe written, gate open.
printf 'import urllib.request\n\ndef fetch(url):\n    return urllib.request.urlopen(url).read()\n' > client.py
printf 'from client import fetch\n\ndef load(url):\n    return fetch(url)\n' > app.py
git add -A && git_q commit -qm init
s=.cookbook/fetch-retry; mkdir -p "$s"
cat > "$s/brief.md" <<'B'
# Brief: fetch-retry
Problem: fetch() fails on a transient network error.
Decision: retry three times with a fixed one-second wait.
Done-check: `python -m pytest tests/test_client.py` passes with a test where the first two calls raise URLError.
B
cat > "$s/recipe.md" <<'R'
# Recipe: fetch-retry
## Problem
fetch() fails on a transient network error.
## Usage
`fetch(url)` keeps its signature and retries inside.
## Shape
A loop inside `fetch`: three attempts, one-second wait, re-raise the last URLError.
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
cat > "$s/ledger.md" <<'L'
# fetch-retry
ask: add retry to the fetch client
phase: recipe
size: standard, done-check clear, one unit, no reach, no risk, shape open
size changes:
gates: brief 2026-11-10, recipe open

| unit | check | parallel | status | fails | evidence |
|---|---|---|---|---|---|

events:
L
