wt="$W/wt/fetch-retry"
cp .cookbook/dishes/fetch-retry/ledger.md "$W/ledger-turn1"
# The dish is built in its worktree: an edit or a commit there is a source change.
{ git -C "$wt" status --porcelain; git -C "$wt" log --format='commit %s' "$(git rev-parse HEAD)..HEAD"; } > "$W/status-turn1"
