. "$(dirname "$0")/../../lib.sh"
agent_ended
# The ledger is in the cookbook of the main checkout, and Git ignores the cookbook there: the check ran where the ledger is written.
set -- .cookbook/dishes/*/ledger.md
[ "$#" -eq 1 ] && [ -f "$1" ] || fail "want one ledger in the main checkout, got: $*"
[ ! -e "$W/wt/orders/.cookbook" ] || fail "a second cookbook in the linked worktree"
git check-ignore -q .cookbook/x || fail "Git does not ignore .cookbook/ in the main checkout"
clean_tree "$REPO"; clean_tree "$W/wt/orders"
