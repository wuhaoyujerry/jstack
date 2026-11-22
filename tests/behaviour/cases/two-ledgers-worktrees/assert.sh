. "$(dirname "$0")/../../lib.sh"
agent_ended
# The dish is chosen before its worktree counts: the session asks which of the two the user means, and nothing on disk moved.
diff -r "$W/cookbook-before" .cookbook > /dev/null || fail "a ledger changed"
has "$OUT" 'fetch-retry'; has "$OUT" 'retry-fetch-client'; has "$OUT" '\?|[Ww]hich (one|dish|ledger)'
no_workers
clean_tree "$REPO"; clean_tree "$W/wt/fetch-retry"; clean_tree "$W/wt/retry-fetch-client"; clean_tree "$ROOT"
