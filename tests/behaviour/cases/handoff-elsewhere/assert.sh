. "$(dirname "$0")/../../lib.sh"
agent_ended
# The dish continues only in its worktree: the session in the main checkout names that worktree to the user and changes nothing.
has "$OUT" 'wt/fetch-retry'
diff -r "$W/before" .cookbook > /dev/null || fail "the cookbook changed: $(diff -rq "$W/before" .cookbook | head -3)"
no_workers
clean_tree "$REPO"; clean_tree "$W/wt/fetch-retry"; clean_tree "$ROOT"
