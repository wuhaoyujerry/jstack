# A standard dish in the idea phase. The user has settled every decision; the brief holds the five decisions and the closing line.
# Three of them carry a mechanism and run past 20 words. Together they leave no choice open: which errors `fetch` retries, what
# it raises after the last attempt, and how a retry is logged.
printf 'import urllib.request\n\ndef fetch(url):\n    return urllib.request.urlopen(url).read()\n' > client.py
printf 'from client import fetch\n\ndef load(url):\n    return fetch(url)\n' > app.py
printf 'from client import fetch\n\ndef probe(url):\n    """Health probe."""\n    return fetch(url)\n' > probe.py
git add -A && git_q commit -qm init
mkdir -p .cookbook/dishes/fetch-retry
cat > .cookbook/dishes/fetch-retry/ledger.md <<'L'
# fetch-retry
ask: add retry to the fetch client
phase: idea
size: standard, done-check open, one unit, no reach, no risk, shape open
size changes:
gates: brief open, recipe open

| unit | check | parallel | status | fails | evidence |
|---|---|---|---|---|---|

events:
- 2026-11-10: The user answered the last round. The brief holds the five decisions the user made.
- 2026-11-10: The user said that no other decision is open and that no research is needed, and asked for the brief.
L
cat > .cookbook/dishes/fetch-retry/brief.md <<'B'
# Brief: fetch-retry
## Decisions
- D1 Attempts. `fetch` tries a URL three times at most. (2026-11-10)
- D2 Wait. `fetch` waits one second between attempts with `time.sleep(1)`, and the test replaces it through `unittest.mock.patch("client.time.sleep")` so that the test runs in under one second. (2026-11-10)
- D3 Errors. `fetch` retries a network failure, which is a `urllib.error.URLError` that is not an `HTTPError`, and an HTTP status of 500 or more; it raises every other error at once, a status under 500 included, and after the third failed attempt it raises the error of that attempt. (2026-11-10)
- D4 Probe. The health probe in `probe.py` calls `fetch` with `attempts=1`, so a failing host is reported after one attempt and the probe never waits. (2026-11-10)
- D5 Log. Each retry writes one warning through `logging.warning`. (2026-11-10)
- Closing question. Nothing is missing. (2026-11-10)
B
