# A standard dish in the idea phase. The user has settled every decision that the agent listed; no research is pending.
# The brief holds those four decisions and no closing line: nobody has asked the user what the interview missed.
printf 'import urllib.request\n\ndef fetch(url):\n    return urllib.request.urlopen(url).read()\n' > client.py
printf 'from client import fetch\n\ndef load(url):\n    return fetch(url)\n' > app.py
git add -A && git_q commit -qm init
mkdir -p .cookbook/dishes/fetch-retry
cat > .cookbook/dishes/fetch-retry/ledger.md <<'L'
# fetch-retry
ask: add retry to the fetch client
meal: none
worktree: none
phase: idea
size: standard, done-check open, one unit, no reach, no risk, shape open
size changes:
overlays: missing
gates: brief open, recipe open

| unit | check | parallel | status | fails | evidence |
|---|---|---|---|---|---|

events:
- 2026-11-10: The user answered the last round. The brief holds the four decisions the user made.
- 2026-11-10: The agent found no other decision to ask, and no research is pending.
L
cat > .cookbook/dishes/fetch-retry/brief.md <<'B'
# Brief: fetch-retry
## Decisions
- D1 Attempts. `fetch` tries a URL three times at most. (2026-11-10)
- D2 Wait. `fetch` waits one second between attempts. (2026-11-10)
- D3 Errors. `fetch` retries a network failure and a status of 500 or more. (2026-11-10)
- D4 Log. Each retry writes one warning to the log. (2026-11-10)
B
