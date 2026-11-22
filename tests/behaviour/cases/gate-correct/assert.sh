. "$(dirname "$0")/../../lib.sh"
agent_ended
l=.cookbook/dishes/fetch-retry/ledger.md
# The correction is on disk for review to read, the recipe follows it, and the gate stays open.
sed -n '/^events:/,$p' "$l" | grep -Eqi 'fetch_with_retry|correct' || fail "ledger events lack the user's correction"
has .cookbook/dishes/fetch-retry/recipe.md 'fetch_with_retry'
has "$l" '^gates: brief 2026-11-10, recipe open'
# The dish is built in its worktree: an edit or a commit there is a source change.
wt="$W/wt/fetch-retry"
[ -z "$(git -C "$wt" status --porcelain; git -C "$wt" log --format='commit %s' "$(git rev-parse HEAD)..HEAD")" ] || fail "source changed before approval"
clean_tree "$ROOT"
