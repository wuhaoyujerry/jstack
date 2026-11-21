. "$(dirname "$0")/../../lib.sh"
agent_ended
[ ! -e .cookbook/hook-ran.txt ] || fail "a hook ran from an overlay that does not apply"
has .cookbook/dishes/rename-parse/ledger.md '^phase: done'
clean_tree "$REPO"; clean_tree "$ROOT"; no_workers
