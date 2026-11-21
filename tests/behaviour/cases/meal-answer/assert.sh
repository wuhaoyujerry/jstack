. "$(dirname "$0")/../../lib.sh"
agent_ended
d=.cookbook/meals/checkout/cart-export
# Turn 1: the meal agent shows the dish's question to the user, with the dish's name, and answers nothing itself.
has "$OUT" 'cart-export'; has "$OUT" 'cart as CSV'
lacks "$W/orca-turn1.log" '(^| )orchestration (reply|send|ask)( |$)'
# Turn 2: the user's answer goes back to the dish as the reply to its message.
n="$(orca_calls reply | grep -c .)"
[ "$n" -eq 1 ] || fail "want one reply, got $n: $(cat "$ORCA_LOG")"
orca_calls reply | grep -Eq -- '--id msg_q1( |$)' || fail "the reply names another message: $(orca_calls reply)"
grep -Eiq 'approv' "$ORCA_LOG" || fail "the reply lacks the user's answer: $(cat "$ORCA_LOG")"
# The dish records its own gate: the meal agent cooks no dish and starts none again.
has "$d/ledger.md" '^gates: brief open, recipe open'
[ ! -e "$d/recipe.md" ] || fail "the meal agent wrote the recipe of a dish"
[ -z "$(worker_starts)" ] || fail "started a worker: $(worker_starts)"
clean_tree "$REPO"; clean_tree "$W/wt/checkout"; clean_tree "$ROOT"
