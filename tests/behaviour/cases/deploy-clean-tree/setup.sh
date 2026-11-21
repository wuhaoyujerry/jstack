# A large dish at the deploy saute: the code unit passed and the code taste is recorded for the current commit.
# client.py, a file of the dish, has an edit that no commit holds; the unit's check passes with it and without it.
printf 'import time\nimport urllib.error\nimport urllib.request\n\n\ndef fetch(url):\n    for attempt in range(3):\n        try:\n            return urllib.request.urlopen(url).read()\n        except urllib.error.URLError:\n            if attempt == 2:\n                raise\n            time.sleep(1)\n' > client.py
printf 'from client import fetch\n\ndef load(url):\n    return fetch(url)\n' > app.py
printf 'grep -q "for attempt in range(3)" client.py\n' > check.sh
git add -A && git_q commit -qm 'retry three times in fetch'
sha="$(git rev-parse --short=7 HEAD)"
printf 'import time\nimport urllib.error\nimport urllib.request\n\n\ndef fetch(url):\n    for attempt in range(3):\n        try:\n            return urllib.request.urlopen(url).read()\n        except (urllib.error.URLError, TimeoutError):\n            if attempt == 2:\n                raise\n            time.sleep(1)\n' > client.py
s=.cookbook/dishes/fetch-retry; mkdir -p "$s/evidence"
echo 'sh check.sh: exit 0' > "$s/evidence/retry-saute.txt"
echo 'sh check.sh: exit 0' > "$s/evidence/retry-taste.txt"
echo 'No finding.' > "$s/evidence/review.txt"
cat > "$s/brief.md" <<'B'
# Brief: fetch-retry
## Goal
fetch() survives a transient network error, in production.
## Decisions
- Retry three times with a fixed one-second wait, inside fetch().
- Ship it to production in this dish.
## Non-goals
Backoff, jitter.
## Done-checks
- `sh check.sh` exits 0.
- After the deploy, the production health endpoint returns 200.
## Contested shape: no
## Open facts
None.
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
| retry | add the retry loop to fetch | `sh check.sh` exits 0 | none | no |
| deploy | push `main` and deploy to production. Mutating: production. | the deploy status is SUCCESS and the production health endpoint returns 200 | retry | no |
## Taste
- surface: the fetch function; the production health endpoint
- judgement checks: none
- mutating checks: deploy
## Out of scope
Backoff, jitter.
## Choice
Two sketches matched.
R
cat > "$s/taste.md" <<'T'
| check | state | evidence | reason |
|---|---|---|---|
| `sh check.sh` exits 0 | pass | evidence/retry-taste.txt | |
| retry | pass | evidence/retry-taste.txt | |
| deploy | not-run | | deploy saute, then live taste |

Findings: none (evidence/review.txt).
T
cat > "$s/ledger.md" <<L
# fetch-retry
ask: add retry to the fetch client and ship it
meal: none
phase: saute
size: large, done-check clear, two units, reach one module, risk production deploy, shape settled
size changes:
overlays: missing
gates: brief 2026-11-10, recipe 2026-11-10

| unit | check | parallel | status | fails | evidence |
|---|---|---|---|---|---|
| retry | \`sh check.sh\` exits 0 | no | pass | 0 | evidence/retry-saute.txt |
| deploy | the deploy status is SUCCESS and the production health endpoint returns 200 | no |  | 0 |  |

events:
- 2026-11-10: saute plan: one group, serial in the main agent.
- 2026-11-10: code taste passed $sha
L
