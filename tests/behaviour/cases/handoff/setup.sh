# A standard dish at the brief gate in the main checkout: the interview is done, the brief is written and its gate summary was shown.
# WORKTREE names the dish worktree in the ledger, BRIEF_GATE gives the brief gate its date, and EVENT adds a ledger event.
printf 'import urllib.request\n\ndef fetch(url):\n    return urllib.request.urlopen(url).read()\n' > client.py
printf 'from client import fetch\n\ndef load(url):\n    return fetch(url)\n' > app.py
git add -A && git_q commit -qm init
s=.cookbook/dishes/fetch-retry; mkdir -p "$s"
cat > "$s/brief.md" <<'B'
# Brief: fetch-retry
## Goal
The fetch client survives a transient network error.
## What it does
- A failed fetch is tried again, up to three times.
- After the third failure the caller gets the last error.
## How we check
- A test makes the first two calls fail and sees the third answer.
## Done-checks
- A fetch whose first two calls raise a network error returns the third answer.
## Non-goals
Backoff, jitter.
## Open facts
- `python -m pytest tests/test_client.py` is the check; the error is `urllib.error.URLError`.
## Contested shape: no
## Decisions
- Retry three times with a fixed one-second wait, then raise the last error.
B
cat > "$s/ledger.md" <<L
# fetch-retry
ask: add retry to the fetch client
meal: none
worktree: ${WORKTREE:-none}
phase: idea
size: standard, done-check clear, one unit, no reach, no risk, shape open
size changes:
overlays: missing
gates: brief ${BRIEF_GATE:-open}, recipe open

| unit | check | parallel | status | fails | evidence |
|---|---|---|---|---|---|

events:
- 2026-11-10 interview done: no decision open, no research pending; brief written and its gate summary shown; the split test found one part
${EVENT:-}
L
