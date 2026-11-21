# The meal-next fixture after the handoff of the meal: the meal file names the meal worktree and its branch, and the session starts
# in that worktree (the `cwd` file).
. "$(dirname "$0")/../meal-next/setup.sh"
wt="$(cd "$W" && pwd -P)/wt/checkout"
git worktree add -q -b checkout "$wt"
m=.cookbook/meals/checkout/meal.md
awk -v w="$wt" '{ print } /^goal:/ { print "worktree: " w; print "branch: checkout" }' "$m" > "$m.new" && mv "$m.new" "$m"
rm -rf "$W/before" && cp -R .cookbook "$W/before"
