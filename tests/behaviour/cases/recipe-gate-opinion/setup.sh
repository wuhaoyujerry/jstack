# A standard dish at the recipe gate: brief approved, gate open; the recipe came from one sketch and keeps to the brief. The brief
# leaves one outcome to an opinion that the user was never asked to settle, and the recipe marks its check as a judgement check.
# OPINION_DECISION adds one decision to the brief: the user's answer on that opinion.
# The dish was handed off after the brief gate: the ledger names the dish worktree, and the session starts there (the `cwd` file).
wt="$(cd "$W" && pwd -P)/wt/fetch-retry"
printf 'import urllib.request\n\ndef fetch(url):\n    return urllib.request.urlopen(url).read()\n' > client.py
printf 'from client import fetch\n\ndef load(url):\n    return fetch(url)\n' > app.py
git add -A && git_q commit -qm init
s=.cookbook/dishes/fetch-retry; mkdir -p "$s"
cat > "$s/brief.md" <<'B'
# Brief: fetch-retry
## Goal
The fetch client survives a transient network error and fails with a clear message.
## What it does
- A failed fetch is tried again: three tries in all.
- After the third failure the caller gets a failure message.
## How we check
- A test makes the first two calls fail and sees the third answer.
- We read the failure message.
## Done-checks
- A fetch whose first two calls raise a network error returns the third answer.
- The failure message reads as calm and plain to a reader who is not technical.
## Non-goals
Backoff, jitter.
## Open facts
- `python -m pytest tests/test_client.py` is the check of the retry; the error is `urllib.error.URLError`.
- `FetchError` is a new error class in `client.py`; its text is the failure message.
## Contested shape: no
## Decisions
- A fetch gets three tries in all, with a fixed one-second wait between tries.
- After the third failure, `fetch` raises `FetchError` with the failure message.
B
[ -z "${OPINION_DECISION:-}" ] || printf '%s\n' "- $OPINION_DECISION" >> "$s/brief.md"
cat > "$s/recipe.md" <<'R'
# Recipe: fetch-retry
## Problem
fetch() fails on a transient network error, and it has no failure message of its own.
## Usage
`fetch(url)` keeps its signature and retries inside.
## Shape
A loop inside `fetch`: three tries in all, a one-second wait between tries. After the third failure it raises `FetchError` with the failure message.
## Units
| id | change | check | depends on | parallel |
|---|---|---|---|---|
| retry | add the retry loop to fetch and a test for it | `python -m pytest tests/test_client.py` passes | none | no |
| message | word the failure message of `FetchError` | a reader finds the message calm and plain | retry | no |
## Taste
- surface: the fetch function and the message of its last error
- judgement checks: message
- mutating checks: none
- live checks: none
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
size: standard, done-check clear, several units, no reach, no risk, shape open
size changes:
overlays: missing
gates: brief 2026-11-10, recipe open

| unit | check | parallel | status | fails | evidence |
|---|---|---|---|---|---|

events:
- 2026-11-10 brief approved; handed off to $wt
L
git worktree add -q -b fetch-retry "$wt"
