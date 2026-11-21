# The meal-coordinate fixture one step later: the meal agent started both open dishes as its workers, each in a child worktree from
# the meal branch. cart-export is at its brief gate: the interview is done and the brief is written, and no one has seen its gate summary.
. "$(dirname "$0")/../meal-coordinate/setup.sh"
m=.cookbook/meals/checkout
base="$(cd "$W" && pwd -P)/wt"
ledger cart-export 'export a cart as CSV' idea 'standard, done-check clear, one unit, reach public function, no risk, shape settled' \
  'brief open, recipe open' '' \
  "- 2026-11-11 interview done: no decision open, no research pending; brief written; the split test found one part"
cat > "$m/cart-export/brief.md" <<'B'
# Brief: cart-export
## Goal
An operator can export a cart as CSV.
## What it does
- Writes one row for each item in the cart.
- Ends the file with a row that holds the total.
## How we check
- A test exports a cart of two items and reads the rows back.
## Done-checks
- `python -m pytest test_export.py` passes: a two-item cart gives the header, two rows and the total row.
## Non-goals
Other formats, other transports.
## Open facts
None.
## Contested shape: no
## Decisions
- Shared: `.cookbook/meals/checkout/meal.md`.
- A new public function `export_csv(cart, path)` in a new module `export.py` writes the header `price,qty`, one row per item, and a last row with the total from `cart.total`.
B
for d in cart-export cart-email; do
  git worktree add -q -b "$d" "$base/$d" checkout
  awk -v w="$base/$d" '{ print } /^meal:/ { print "worktree: " w } /^- 2026-11-10 split/ { print "- 2026-11-11 started by the meal agent as its worker, in " w }' \
    "$m/$d/ledger.md" > "$m/$d/ledger.md.new" && mv "$m/$d/ledger.md.new" "$m/$d/ledger.md"
done
rm -rf "$W/before" && cp -R .cookbook "$W/before"
