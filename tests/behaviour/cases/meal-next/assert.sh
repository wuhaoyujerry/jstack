. "$(dirname "$0")/../../lib.sh"
agent_ended
# The meal chooses the dish: the second is sized; the done dish, the third dish and the meal file stay as they were.
has .cookbook/cart-export/ledger.md '^size: (trivial|standard|large)'
diff -r "$W/before/cart-totals" .cookbook/cart-totals > /dev/null || fail "the done dish changed"
diff -r "$W/before/cart-email" .cookbook/cart-email > /dev/null || fail "the third dish changed"
same_file "$W/before/meals/checkout.md" .cookbook/meals/checkout.md
set -- .cookbook/*/ledger.md
[ "$#" -eq 3 ] || fail "want three ledgers, got: $*"
clean_tree "$ROOT"
