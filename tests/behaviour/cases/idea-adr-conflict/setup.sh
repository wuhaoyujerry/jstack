# A standard dish in the idea phase. The user settled every decision, answered the closing question and asked for the brief. One of them contradicts an ADR of
# the repo, which the user has not seen in this dish; no code or packaging file shows the constraint.
printf 'import urllib.request\n\ndef fetch(url):\n    return urllib.request.urlopen(url).read()\n' > client.py
printf 'from client import fetch\n\ndef load(url):\n    return fetch(url)\n' > app.py
printf 'from client import fetch\n\ndef probe(url):\n    """Health probe."""\n    return fetch(url)\n' > probe.py
mkdir -p docs/adr
cat > docs/adr/0001-standard-library-only.md <<'A'
# The client uses the standard library only

The client is copied as one file into images that have no package installer, so it imports nothing outside the standard library.
A
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
- 2026-11-10: The user answered the last round. The brief holds the three decisions the user made.
- 2026-11-10: The user said that no other decision is open and that no research is needed, and asked for the brief.
L
cat > .cookbook/dishes/fetch-retry/brief.md <<'B'
# Brief: fetch-retry
## Decisions
- D1 Library. The retry uses the `tenacity` package. (2026-11-10)
- D2 Attempts. `fetch` tries a URL three times at most. (2026-11-10)
- D3 Wait. `fetch` waits one second between attempts. (2026-11-10)
- Closing question. Nothing is missing. (2026-11-10)
B
