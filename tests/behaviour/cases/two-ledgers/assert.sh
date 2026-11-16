. "$(dirname "$0")/../../lib.sh"
agent_ended
# Asks which ledger before any other action: nothing on disk moved.
[ "$(ls .jstack | wc -l)" -eq 2 ] || fail "ledger count is $(ls .jstack | wc -l), want 2"
diff -r "$W/jstack-before" .jstack > /dev/null || fail "a ledger changed"
clean_tree "$REPO"; clean_tree "$ROOT"; no_workers
has "$OUT" 'fetch-retry'; has "$OUT" 'retry-fetch-client'; has "$OUT" '\?'
