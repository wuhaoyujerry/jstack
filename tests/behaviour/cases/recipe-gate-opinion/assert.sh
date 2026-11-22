. "$(dirname "$0")/../../lib.sh"
agent_ended
l=.cookbook/dishes/fetch-retry/ledger.md
# The opinion behind the judgement check is a gap: the reply puts the message to the user, as a question or as a request to approve.
has "$OUT" 'calm|plain|[Mm]essage|[Ww]ording'
# The gate waits for the answer: it stays open, no unit reaches the ledger and no source changes.
has "$l" '^gates: brief 2026-11-10, recipe open'
lacks "$l" '^\| *retry'
[ -z "$(git status --porcelain)" ] || fail "source changed before the answer"
clean_tree "$ROOT"
