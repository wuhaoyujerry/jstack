# The meal-merge fixture with a conflict: after cart-export branched, the meal branch gained its own export.py, so the merge of
# the done dish fails. The report of cart-export is the mail in the meal agent's inbox (the `orca-inbox` file).
. "$(dirname "$0")/../meal-merge/setup.sh"
meal_wt="$(cd "$W" && pwd -P)/wt/checkout"
printf 'def export_csv(cart, path):\n    raise NotImplementedError\n' > "$meal_wt/export.py"
(cd "$meal_wt" && git add -A && git_q commit -qm 'export stub')
git -C "$meal_wt" rev-parse HEAD > "$W/meal-head"
mkdir -p "$ROOT/logs"
: > "$ROOT/logs/review-log.md"
: > "$ROOT/logs/sizing-log.md"
