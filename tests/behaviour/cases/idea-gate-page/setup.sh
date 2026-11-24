# A standard dish in the idea phase. The user settled every decision, answered the closing question and asked for the brief.
# The change has parts that connect: attempts, a wait and a last error. Three decisions carry a mechanism, which the page must
# not show. The page tool is the real answer-me-with-html: this case needs it installed.
tool=""
for t in "$HOME/.agents/skills/answer-me-with-html/scripts/am.mjs" "$HOME/.claude/skills/answer-me-with-html/scripts/am.mjs"; do
  if [ -z "$tool" ] && [ -r "$t" ]; then tool="$t"; fi
done
[ -n "$tool" ] || { echo "setup: answer-me-with-html is not installed; this case needs the real tool"; exit 1; }
printf 'export IDEA_PAGE_TOOL="%s"\n' "$tool" >> "$W/bashenv"
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
- 2026-11-10: The user answered the closing question: nothing is missing. No research is pending. The user asked for the brief.
L
cat > .cookbook/dishes/fetch-retry/brief.md <<'B'
# Brief: fetch-retry
## Decisions
- D1 Attempts. `fetch` tries a URL three times at most. (2026-11-10)
- D2 Wait. `fetch` waits one second between attempts with `time.sleep(1)`, and the test replaces it through `unittest.mock.patch("client.time.sleep")` so that the test runs in under one second. (2026-11-10)
- D3 Errors. `fetch` retries a network failure, which is a `urllib.error.URLError` that is not an `HTTPError`, and an HTTP status of 500 or more; it raises every other error at once, and after the third failed attempt it raises the error of that attempt. (2026-11-10)
- D4 Log. Each retry writes one warning through `logging.warning`. (2026-11-10)
- Closing question. Nothing is missing. (2026-11-10)
B
