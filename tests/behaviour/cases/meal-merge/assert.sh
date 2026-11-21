. "$(dirname "$0")/../../lib.sh"
agent_ended
m=.cookbook/meals/checkout
# The meal agent merges the done dish into the meal branch.
git merge-base --is-ancestor cart-export checkout || fail "the meal branch lacks the work of cart-export"
# Then it starts the dish that waited for it, as a worker in a child worktree from the meal branch, and names the worktree in the ledger.
n="$(worker_starts | grep -c .)"
[ "$n" -eq 1 ] || fail "want one worker start, got $n: $(cat "$ORCA_LOG")"
worker_starts | grep -E -- '--name cart-email( |$)' | grep -E -- '--worktree new-child( |$)' | grep -Eq -- '--base-branch (refs/heads/)?checkout( |$)' \
  || fail "no worker for cart-email in a child worktree from the meal branch: $(worker_starts)"
git merge-base --is-ancestor cart-export cart-email || fail "cart-email started before the merge: its worktree lacks the work of cart-export"
has "$m/cart-email/ledger.md" '^worktree: .*wt/cart-email'
# It cooks no dish itself: cart-email is not sized here, and the two done dishes stay as they were. The ledger of the merged dish
# may gain events, such as the merge.
has "$m/cart-email/ledger.md" '^size: *$'
diff -r "$W/before/meals/checkout/cart-totals" "$m/cart-totals" > /dev/null || fail "the done dish cart-totals changed"
only_new_events "$W/before/meals/checkout/cart-export" "$m/cart-export"
lacks "$ORCA_LOG" '(^| )worktree create( |$)'
clean_tree "$REPO"; clean_tree "$W/wt/checkout"; clean_tree "$ROOT"
