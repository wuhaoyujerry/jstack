. "$(dirname "$0")/../../lib.sh"
agent_ended
m=.cookbook/meals/checkout
# The meal agent starts each ready dish as a worker in a child worktree from the meal branch, and names that worktree in the dish's ledger.
n="$(worker_starts | grep -c .)"
[ "$n" -eq 2 ] || fail "want two worker starts, got $n: $(cat "$ORCA_LOG")"
for d in cart-export cart-email; do
  worker_starts | grep -E -- "--name $d( |\$)" | grep -E -- '--worktree new-child( |$)' | grep -Eq -- '--base-branch (refs/heads/)?checkout( |$)' \
    || fail "no worker for $d in a child worktree from the meal branch: $(worker_starts)"
  has "$m/$d/ledger.md" "^worktree: .*wt/$d"
  # It cooks no dish itself: neither is sized here.
  has "$m/$d/ledger.md" '^size: *$'
done
lacks "$ORCA_LOG" '(^| )worktree create( |$)'
diff -r "$W/before/meals/checkout/cart-totals" "$m/cart-totals" > /dev/null || fail "the done dish changed"
clean_tree "$REPO"; clean_tree "$W/wt/checkout"; clean_tree "$ROOT"
