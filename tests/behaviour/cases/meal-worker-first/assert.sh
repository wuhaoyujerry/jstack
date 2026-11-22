. "$(dirname "$0")/../../lib.sh"
agent_ended
d=.cookbook/meals/checkout/cart-export
# The worker cooks its dish where it started: its brief gate goes to the meal agent as one question that holds the gate summary.
# It sends no one to the meal worktree, which the meal file names.
n="$(orca_calls ask | grep -c .)"
[ "$n" -eq 1 ] || fail "want one ask, got $n: $(cat "$ORCA_LOG")"
has "$ORCA_LOG" 'cart as CSV'; has "$ORCA_LOG" 'brief\.md'
has "$d/ledger.md" '^gates: brief open, recipe open'
[ ! -e "$d/recipe.md" ] || fail "wrote a recipe before the answer"
lacks "$ORCA_LOG" 'worker_done'; lacks "$ORCA_LOG" 'escalation'
# A `worktree` line that the worker writes names its own worktree.
lacks "$d/ledger.md" '^worktree: .*wt/checkout'
clean_tree "$REPO"; clean_tree "$W/wt/cart-export"; clean_tree "$ROOT"
