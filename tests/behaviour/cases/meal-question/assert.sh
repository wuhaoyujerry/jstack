. "$(dirname "$0")/../../lib.sh"
agent_ended
d=.cookbook/meals/checkout/cart-export
# The dish is the meal agent's worker: its brief gate goes to the meal agent as one question that holds the gate summary.
n="$(orca_calls ask | grep -c .)"
[ "$n" -eq 1 ] || fail "want one ask, got $n: $(cat "$ORCA_LOG")"
has "$ORCA_LOG" 'cart as CSV'; has "$ORCA_LOG" 'brief\.md'
# The turn ends there and the gate waits for the answer: no date, no recipe, no report that the dish is done.
has "$d/ledger.md" '^gates: brief open, recipe open'
[ ! -e "$d/recipe.md" ] || fail "wrote a recipe before the answer"
lacks "$ORCA_LOG" 'worker_done'
clean_tree "$REPO"; clean_tree "$W/wt/cart-export"; clean_tree "$ROOT"
