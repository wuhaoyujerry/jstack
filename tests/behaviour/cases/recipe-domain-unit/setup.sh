# The handoff-linked fixture, with a brief that settled one term and marks one decision ADR. The repo has no glossary and no ADR.
. "$(dirname "$0")/../handoff-linked/setup.sh"
cat > .cookbook/dishes/fetch-retry/brief.md <<'B'
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
- Retry placement, alternatives: a wrapper that each caller applies. Reason for the choice: a caller that forgets the wrapper fails silently, and every caller needs the retry.
## Terms
- Attempt: one call from the fetch client to the network, the first call included.
## Contested shape: no
## Decisions
- Retry three attempts with a fixed one-second wait, then raise the last error.
- The retry lives inside the fetch client, not in its callers. ADR
B
