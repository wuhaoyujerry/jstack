# A standard dish in the idea phase. An earlier session recorded three points the user left undecided;
# none depends on another, and no file in the repo answers them.
printf 'import urllib.request\n\ndef fetch(url):\n    return urllib.request.urlopen(url).read()\n' > client.py
printf 'from client import fetch\n\ndef load(url):\n    return fetch(url)\n' > app.py
printf 'from client import fetch\n\ndef probe(url):\n    """Health probe."""\n    return fetch(url)\n' > probe.py
git add -A && git_q commit -qm init
mkdir -p .cookbook/fetch-retry
cat > .cookbook/fetch-retry/ledger.md <<'L'
# fetch-retry
ask: add retry to the fetch client
phase: idea
size: standard, done-check open, one unit, no reach, no risk, shape open
size changes:
gates: brief open, recipe open

| unit | check | parallel | status | fails | evidence |
|---|---|---|---|---|---|

events:
- 2026-11-10: The user left three points undecided and asked to be asked about each: whether the health probe also retries, whether each attempt gets a timeout, and whether each retry is logged.
L
