. "$(dirname "$0")/../../lib.sh"
agent_ended
[ -s .check-runs ] || fail "the unit's check did not run again"
[ "$(ls .jstack | wc -l)" -eq 1 ] || fail "a second ledger was created"
has .jstack/rename-parse/ledger.md '^phase: (taste|review|done)'
# Review changes only the logs and the ledger; logs go to the overlay directory, outside the skill.
clean_tree "$REPO"; clean_tree "$ROOT"; no_workers
