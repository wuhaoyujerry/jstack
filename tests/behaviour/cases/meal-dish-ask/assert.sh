. "$(dirname "$0")/../../lib.sh"
agent_ended
m=.cookbook/meals/checkout
# The main checkout hands off the meal, not the dish: one worktree named for the meal, which the meal file names.
n="$(grep -cE -- '(^| )worktree create( |$)' "$ORCA_LOG")"
[ "$n" -eq 1 ] || fail "want one worktree create, got $n: $(cat "$ORCA_LOG")"
has "$ORCA_LOG" '--name checkout( |$)'
has "$m/meal.md" '^worktree: .*wt/checkout'
# The meal worktree is no dish's worktree: a ledger that named it would keep the meal agent from starting that dish.
for d in cart-totals cart-export cart-email; do lacks "$m/$d/ledger.md" '^worktree: .*wt/'; has "$m/$d/ledger.md" "$(grep '^phase:' "$W/before/meals/checkout/$d/ledger.md")"; done
[ -z "$(worker_starts)" ] || fail "the main checkout started a dish worker: $(worker_starts)"
clean_tree "$REPO"; clean_tree "$ROOT"
