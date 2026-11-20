# The meal-next fixture, but the done dish's work is on the branch cart-totals and the current branch lacks it.
export WORK_BRANCH=cart-totals DEP3=cart-export
. "$(dirname "$0")/../meal-next/setup.sh"
git rev-parse --abbrev-ref HEAD > "$W/branch-before"
