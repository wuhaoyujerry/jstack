# A standard dish in the idea phase. The user settled every decision, answered the closing question and asked for the brief.
# Two decisions that stand apart cannot both hold, and only their effect on one example shows it: every caller gets the retry
# (D6), which waits one second between three attempts (D1, D2), and the status line reports a host that is down within one
# second (D7). No ADR shows the conflict.
printf 'import urllib.request\n\ndef fetch(url):\n    return urllib.request.urlopen(url).read()\n' > client.py
printf 'from client import fetch\n\ndef load(url):\n    return fetch(url)\n' > app.py
printf 'from app import load\n\ndef status_line(url):\n    """One line of the status page."""\n    try:\n        load(url)\n        return "up"\n    except Exception:\n        return "down"\n' > status.py
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
- 2026-11-10: The user answered the last round. The brief holds the seven decisions the user made.
- 2026-11-10: The user answered the closing question: nothing is missing. No research is pending. The user asked for the brief.
L
cat > .cookbook/dishes/fetch-retry/brief.md <<'B'
# Brief: fetch-retry
## Decisions
- D1 Attempts. `fetch` tries a URL three times at most. (2026-11-10)
- D2 Wait. `fetch` waits one second between attempts. (2026-11-10)
- D3 Errors. `fetch` retries a network failure and a status of 500 or more. (2026-11-10)
- D4 Log. Each retry writes one warning to the log. (2026-11-10)
- D5 Last error. After the last attempt `fetch` raises the error of that attempt. (2026-11-10)
- D6 Callers. Every caller of `fetch` gets the retry; no caller opts out. (2026-11-10)
- D7 Status. `status_line` reports a host that is down within one second. (2026-11-10)
- Closing question. Nothing is missing. (2026-11-10)
B
