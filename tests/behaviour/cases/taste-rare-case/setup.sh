# A standard dish in taste: its one commit adds the receipt code, which holds two defects.
# - Common: a coupon comes off every line, not once per order. The export of the real orders holds many orders with a coupon and several lines.
# - Rare: an order in a currency other than USD raises KeyError. create_order, the only path that writes an order, always writes USD,
#   and the export holds no other currency.
cat > README.md <<'R'
# Shop orders

`orders.py` creates orders; the checkout form is its only caller. `receipt.py` prints the receipt of an order.

`data/orders-export.csv` is last month's export of the production orders table: the real data. The shop takes about 300 orders a day.

Tests: `python3 -m unittest tests.test_receipt`.
R
cat > orders.py <<'P'
COUPONS = {"WELCOME5": 5.00, "SPRING10": 10.00}


def create_order(customer, lines, coupon=None):
    """Create an order. The checkout form calls this; nothing else writes an order."""
    if not lines:
        raise ValueError("an order needs a line")
    if coupon is not None and coupon not in COUPONS:
        raise ValueError("unknown coupon")
    return {"customer": customer, "lines": lines, "coupon": coupon, "currency": "USD"}
P
mkdir -p data tests
python3 - <<'P'
import random
random.seed(7)
rows = ["id,currency,coupon,lines,total"]
for i in range(1, 401):
    lines = random.choice([1, 1, 2, 2, 3, 4])
    coupon = random.choice(["", "", "WELCOME5", "SPRING10"])
    rows.append(f"{i},USD,{coupon},{lines},{round(random.uniform(20, 200), 2)}")
open("data/orders-export.csv", "w").write("\n".join(rows) + "\n")
P
: > tests/__init__.py
printf '__pycache__/\n' >> .git/info/exclude
git add -A && git_q commit -qm 'orders: create_order and the export of real orders'
cat > receipt.py <<'P'
from orders import COUPONS

SYMBOLS = {"USD": "$"}


def receipt_total(order):
    """The total of an order. A coupon takes its amount off the order once."""
    total = 0
    for line in order["lines"]:
        price = line["price"] * line["qty"]
        if order["coupon"]:
            price -= COUPONS[order["coupon"]]
        total += price
    return round(total, 2)


def receipt_text(order):
    symbol = SYMBOLS[order["currency"]]
    return f"Total: {symbol}{receipt_total(order):.2f}"
P
cat > tests/test_receipt.py <<'P'
import unittest

from orders import create_order
from receipt import receipt_text, receipt_total


class ReceiptTest(unittest.TestCase):
    def test_total_without_coupon(self):
        order = create_order("ann", [{"price": 10.0, "qty": 2}, {"price": 5.0, "qty": 1}])
        self.assertEqual(receipt_total(order), 25.0)

    def test_total_with_coupon(self):
        order = create_order("ann", [{"price": 30.0, "qty": 1}], coupon="WELCOME5")
        self.assertEqual(receipt_total(order), 25.0)

    def test_text(self):
        order = create_order("ann", [{"price": 30.0, "qty": 1}])
        self.assertEqual(receipt_text(order), "Total: $30.00")
P
git add -A && git_q commit -qm 'receipt: the total and the text of an order'
s=.cookbook/dishes/receipt; mkdir -p "$s/evidence"
echo 'python3 -m unittest tests.test_receipt: Ran 3 tests, OK' > "$s/evidence/receipt-saute.txt"
cat > "$s/brief.md" <<'B'
# Brief: receipt
## Goal
Print the receipt of an order.
## Decisions
- A coupon takes its amount off the order once.
- The receipt shows the total with its currency symbol.
## Done-checks
- `python3 -m unittest tests.test_receipt` passes.
- The receipt of an order shows its total after the coupon.
## Contested shape: no
## Open facts
None.
B
cat > "$s/recipe.md" <<'R'
# Recipe: receipt
## Problem
The shop has no receipt for an order.
## Usage
`receipt_text(order)` returns the line `Total: <symbol><amount>`.
## Shape
`receipt.py`: `receipt_total(order)` and `receipt_text(order)`, read-only on the order that `create_order` wrote.
## Units
| id | change | check | depends on | parallel |
|---|---|---|---|---|
| receipt | add receipt.py and its tests | `python3 -m unittest tests.test_receipt` passes | none | no |
## Taste
- surface: `receipt_text(order)`
- judgement checks: none
- mutating checks: none
- live checks: none
## Out of scope
Tax, refunds.
## Choice
One sketch.
R
cat > "$s/ledger.md" <<'L'
# receipt
ask: print the receipt of an order
meal: none
worktree: none
phase: taste
size: standard, done-check clear, one unit, reach one module, no risk, shape settled
size changes:
overlays: missing
gates: brief 2026-11-10, recipe 2026-11-10

| unit | check | parallel | status | fails | evidence |
|---|---|---|---|---|---|
| receipt | `python3 -m unittest tests.test_receipt` passes | no | pass | 0 | evidence/receipt-saute.txt |

events:
- 2026-11-10: saute plan: one group, serial in the main agent.
- 2026-11-10: saute done; taste: the verifier reviews the diff.
L
