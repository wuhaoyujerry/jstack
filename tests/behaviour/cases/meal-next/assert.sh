. "$(dirname "$0")/../../lib.sh"
agent_ended
# The meal chooses the dish: the second is sized; the done dish, the third dish and the meal file stay as they were.
m=.cookbook/meals/checkout
has "$m/cart-export/ledger.md" '^size: (trivial|standard|large)'
diff -r "$W/before/meals/checkout/cart-totals" "$m/cart-totals" > /dev/null || fail "the done dish changed"
diff -r "$W/before/meals/checkout/cart-email" "$m/cart-email" > /dev/null || fail "the third dish changed"
same_file "$W/before/meals/checkout/meal.md" "$m/meal.md"
set -- "$m"/*/ledger.md
[ "$#" -eq 3 ] || fail "want three ledgers, got: $*"
clean_tree "$ROOT"
