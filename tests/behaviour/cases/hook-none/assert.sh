. "$(dirname "$0")/../../lib.sh"
agent_ended
[ ! -e .jstack/hook-ran.txt ] || fail "a hook ran from an overlay that does not apply"
has .jstack/rename-parse/ledger.md '^phase: done'
clean_tree "$REPO"; clean_tree "$ROOT"; no_workers
