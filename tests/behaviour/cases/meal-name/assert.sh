. "$(dirname "$0")/../../lib.sh"
agent_ended
# The split writes one meal folder, and no dish in it has the meal's name.
set -- .cookbook/meals/*/meal.md
[ "$#" -eq 1 ] && [ -f "$1" ] || fail "want one meal file, got: $*"
md="$(dirname "$1")"; meal="$(basename "$md")"
set -- "$md"/*/ledger.md
[ "$#" -eq 2 ] || fail "want two dishes in the meal folder, got: $*"
[ ! -e "$md/$meal" ] || fail "the meal $meal has a dish of the same name"
clean_tree "$REPO"; clean_tree "$ROOT"
