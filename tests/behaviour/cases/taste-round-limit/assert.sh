. "$(dirname "$0")/../../lib.sh"
agent_ended
# The second failed taste stops for the user: the failed check is shown and nothing is fixed before the answer.
same_file "$W/main-before" main.py
lacks .cookbook/dishes/rename-parse/ledger.md '^phase: done'
grep -q 'main\.py' "$OUT" || fail "reply does not show the failed check"
clean_tree "$ROOT"; no_workers
