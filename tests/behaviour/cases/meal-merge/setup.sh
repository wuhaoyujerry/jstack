# The meal-coordinate fixture one step later: cart-export is done in its child worktree, on its own branch, which the meal branch
# lacks, and cart-email waits only for it. The report of cart-export is the mail in the meal agent's inbox (the `orca-inbox` file).
export DEP3=cart-export
. "$(dirname "$0")/../meal-coordinate/setup.sh"
m=.cookbook/meals/checkout
wt="$(cd "$W" && pwd -P)/wt/cart-export"
git worktree add -q -b cart-export "$wt" checkout
cat > "$wt/export.py" <<'P'
import csv

from cart import total


def export_csv(cart, path):
    with open(path, "w", newline="") as f:
        w = csv.writer(f)
        w.writerow(["price", "qty"])
        for i in cart:
            w.writerow([i["price"], i["qty"]])
        w.writerow(["total", total(cart)])
P
cat > "$wt/test_export.py" <<'P'
import csv

from export import export_csv


def test_export(tmp_path):
    p = tmp_path / "cart.csv"
    export_csv([{"price": 2, "qty": 3}, {"price": 1, "qty": 1}], p)
    assert list(csv.reader(open(p))) == [["price", "qty"], ["2", "3"], ["1", "1"], ["total", "7"]]
P
(cd "$wt" && git add -A && git_q commit -qm 'cart export')
ledger cart-export 'export a cart as CSV' 'done' 'standard, done-check clear, one unit, reach public function, no risk, shape settled' \
  'brief 2026-11-11, recipe 2026-11-11' '| export | `python -m pytest test_export.py` passes | no | pass | 0 | evidence/export-saute.txt |' \
  "- 2026-11-11 started by the meal agent as its worker, in $wt
- 2026-11-11 unit export: commit $(git -C "$wt" rev-parse --short HEAD) on branch cart-export
- 2026-11-11 review closed the dish"
awk -v w="$wt" '/^worktree:/ { $0 = "worktree: " w } { print }' "$m/cart-export/ledger.md" > "$m/cart-export/ledger.md.new" && mv "$m/cart-export/ledger.md.new" "$m/cart-export/ledger.md"
mkdir -p "$m/cart-export/evidence" && echo '1 passed' > "$m/cart-export/evidence/export-saute.txt"
rm -rf "$W/before" && cp -R .cookbook "$W/before"
