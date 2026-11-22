# The meal-question fixture a moment earlier: the meal agent started cart-export as its worker, and the worker reads the ledger
# before the meal agent has written the worktree to it. The ledger still reads `worktree: none` and has no event of the start.
. "$(dirname "$0")/../meal-question/setup.sh"
l="$m/cart-export/ledger.md"
grep -v 'started by the meal agent' "$l" | sed 's/^worktree: .*/worktree: none/' > "$l.new" && mv "$l.new" "$l"
rm -rf "$W/before" && cp -R .cookbook "$W/before"
