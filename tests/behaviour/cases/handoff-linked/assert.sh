. "$(dirname "$0")/../../lib.sh"
agent_ended
# The session in the dish worktree finds the cookbook in the main checkout and cooks on from the brief gate: the recipe is written there.
[ -f .cookbook/dishes/fetch-retry/recipe.md ] || fail "no recipe in the cookbook of the main checkout"
[ ! -e "$W/wt/fetch-retry/.cookbook" ] || fail "a second cookbook in the dish worktree"
# It hands the dish to no other worktree, and the source of the main checkout stays as it was.
lacks "$ORCA_LOG" '--name fetch-retry( |$)'
clean_tree "$REPO"; clean_tree "$ROOT"
