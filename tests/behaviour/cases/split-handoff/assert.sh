. "$(dirname "$0")/../../lib.sh"
agent_ended
set -- .cookbook/meals/*/meal.md
[ "$#" -eq 1 ] && [ -f "$1" ] || fail "want one meal file, got: $*"
meal="$1"; md="$(dirname "$meal")"; name="$(basename "$md")"
# After the split the main checkout hands off the meal: one worktree named for the meal, which the meal file names.
n="$(grep -cE -- '(^| )worktree create( |$)' "$ORCA_LOG")"
[ "$n" -eq 1 ] || fail "want one worktree create, got $n: $(cat "$ORCA_LOG")"
has "$ORCA_LOG" "--name $name( |\$)"
has "$meal" "^worktree: .*wt/$name"
# The meal worktree is no dish's worktree: a ledger that named it would keep the meal agent from starting that dish.
set -- "$md"/*/ledger.md
[ "$#" -eq 2 ] || fail "want two ledgers, got: $*"
for l in "$@"; do lacks "$l" '^worktree: .*wt/'; done
[ -z "$(worker_starts)" ] || fail "the main checkout started a dish worker: $(worker_starts)"
clean_tree "$REPO"; clean_tree "$ROOT"
