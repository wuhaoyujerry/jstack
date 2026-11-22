# The meal-blocked fixture after the handoff of the meal: the meal file names the meal worktree, the session starts there (the `cwd`
# file), and the done dish's work is on the branch cart-totals, which the meal branch lacks. No dish names a worktree.
export WORK_BRANCH=cart-totals DEP3=cart-export
. "$(dirname "$0")/../meal-coordinate/setup.sh"
