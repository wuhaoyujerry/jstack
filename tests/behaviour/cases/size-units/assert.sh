. "$(dirname "$0")/../../lib.sh"
agent_ended
# Three units with no reach, no risk and one design: the amount of work alone leaves the dish standard.
set -- .cookbook/*/ledger.md
[ "$#" -eq 1 ] && [ -f "$1" ] || fail "want one ledger, got: $*"
has "$1" '^size: standard'
clean_tree "$REPO"; clean_tree "$ROOT"
