. "$(dirname "$0")/../../lib.sh"
agent_ended
set -- .cookbook/dishes/*/ledger.md
[ "$#" -eq 1 ] && [ -f "$1" ] || fail "want one ledger, got: $*"
has "$1" '^size: large'; has "$1" '^phase: idea'; has "$1" '^gates: brief open, recipe open'
clean_tree "$REPO"; clean_tree "$ROOT"
# Scenario overlay-missing. The data folder has no overlays/ directory: the ledger says so, and nothing creates it before review.
has "$1" '^overlays: .*missing'
[ ! -e "$JSTACK_DATA/overlays" ] || fail "overlays/ was created before review"
