# A standard dish at the recipe gate: brief approved, gate open; the recipe departs from the brief in a decision.
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
A loop inside `fetch`: three attempts, waits of 1, 2 and 4 seconds, re-raise the last URLError.
## Units
| id | change | check | depends on | parallel |
|---|---|---|---|---|
| retry | add the retry loop to fetch and a test for it | `python -m pytest tests/test_client.py` passes | none | no |
## Taste
- surface: the fetch function
- judgement checks: none
- mutating checks: none
## Out of scope
Jitter.
## Choice
One sketch; standard dish. Departs from the brief: the brief decides a fixed one-second wait; this recipe waits 1, 2 and 4 seconds, because a fixed wait keeps hitting a failing host. The user has not answered this.
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
