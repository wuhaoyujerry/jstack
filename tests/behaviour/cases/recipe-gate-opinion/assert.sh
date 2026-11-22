. "$(dirname "$0")/../../lib.sh"
agent_ended
l=.cookbook/dishes/fetch-retry/ledger.md
# The opinion behind the judgement check is a gap: the reply puts the message to the user, as a question or as a request to approve.
has "$OUT" 'calm|plain|[Mm]essage|[Ww]ording'
# The gate waits for the answer: it stays open, no unit reaches the ledger and no source changes.
has "$l" '^gates: brief 2026-11-10, recipe open'
lacks "$l" '^\| *retry'
# The dish is built in its worktree: an edit or a commit there is a source change.
wt="$W/wt/fetch-retry"
[ -z "$(git -C "$wt" status --porcelain; git -C "$wt" log --format='commit %s' "$(git rev-parse HEAD)..HEAD")" ] || fail "source changed before the answer"
clean_tree "$ROOT"
