# The handoff-linked fixture, with a brief of three done-checks. A command shows the first. A reader must look at the second, and
# every reader decides it alike. The third is an opinion on wording, which a decision of the user leaves to the builder.
. "$(dirname "$0")/../handoff-linked/setup.sh"
cat > .cookbook/dishes/fetch-retry/brief.md <<'B'
# Brief: fetch-retry
## Goal
The fetch client survives a transient network error, and a person can see what happened.
## What it does
- A failed fetch is tried again: three tries in all.
- After the third failure the caller gets a failure message.
- A status page lists each address with its retry count.
## How we check
- A test makes the first two calls fail and sees the third answer.
- We open the status page in a narrow browser window.
- We read the failure message.
## Done-checks
- A fetch whose first two calls raise a network error returns the third answer.
- On the status page at 390 px wide, each retry count sits on the same line as its address.
- The failure message reads as calm and plain to a reader who is not technical.
## Non-goals
Backoff, jitter.
## Open facts
- `python -m pytest tests/test_client.py` is the check of the retry; the error is `urllib.error.URLError`.
- `app.py` writes the status page to `status.html`. The repo has no browser test tool: only a page rendered in a browser shows its layout.
- `FetchError` is a new error class in `client.py`; its text is the failure message.
## Contested shape: no
## Decisions
- A fetch gets three tries in all, with a fixed one-second wait between tries.
- After the third failure, `fetch` raises `FetchError` with the failure message.
- The status page is one static file that `app.py` writes.
- The builder words the failure message.
B
