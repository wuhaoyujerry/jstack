# The cookbook-ignored fixture, asked in a linked worktree. The branch there ignores `.cookbook/` in a tracked `.gitignore`;
# the main checkout, which holds the cookbook, does not ignore it.
. "$(dirname "$0")/../cookbook-ignored/setup.sh"
wt="$(cd "$W" && pwd -P)/wt/orders"
git worktree add -q -b orders "$wt"
(cd "$wt" && printf '.cookbook/\n' > .gitignore && git add -A && git_q commit -qm 'ignore the cookbook')
