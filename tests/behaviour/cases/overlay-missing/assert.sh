. "$(dirname "$0")/../../lib.sh"
agent_ended
set -- .cookbook/dishes/*/ledger.md
[ "$#" -eq 1 ] && [ -f "$1" ] || fail "want one ledger, got: $*"
has "$1" '^overlays: .*missing'
[ ! -e "$ROOT/overlays" ] || fail "overlays/ was created before review"
