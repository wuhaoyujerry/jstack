. "$(dirname "$0")/../../lib.sh"
agent_ended
m=.cookbook/meals/checkout
# No dish is ready and none is at work: the meal agent starts and merges nothing, and tells the user which work the meal branch lacks.
has "$OUT" 'cart-totals'
diff -r "$W/before" .cookbook > /dev/null || fail "the cookbook changed: $(diff -rq "$W/before" .cookbook | head -3)"
[ ! -e "$W/wt/checkout/cart.py" ] || fail "the work of cart-totals was brought to the meal branch"
[ "$(git -C "$W/wt/checkout" rev-parse HEAD)" = "$(git rev-parse HEAD)" ] || fail "the meal branch moved"
no_workers
clean_tree "$REPO"; clean_tree "$W/wt/checkout"; clean_tree "$ROOT"
