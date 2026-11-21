. "$(dirname "$0")/../../lib.sh"
agent_ended
# The next dish waits for work that the current branch lacks: no dish is sized, nothing is merged, and the reply names that work.
for d in cart-export cart-email; do
  has ".cookbook/meals/checkout/$d/ledger.md" '^phase: size'; has ".cookbook/meals/checkout/$d/ledger.md" '^size: *$'
done
[ "$(git rev-parse --abbrev-ref HEAD)" = "$(cat "$W/branch-before")" ] || fail "the branch changed to $(git rev-parse --abbrev-ref HEAD)"
[ ! -e cart.py ] || fail "the work of cart-totals was brought to this branch"
has "$OUT" 'cart-totals'
clean_tree "$REPO"; clean_tree "$ROOT"; no_workers
