# A standard dish in taste. Its one commit puts a dollar sign on the receipt and gives the nightly batch a lock.
# - Old: mailer.send_receipt, a caller of the changed receipt_text, fails on an order without an email. The code held it before the
#   diff, the diff opens no path to it, and the export of the real orders holds many guest orders.
# - Rare: two runs that recover one stale lock at the same instant both go on. Only the lock of the diff creates the case; it needs
#   a crashed run and two starts at once, and cron starts the batch once a night.
cat > README.md <<'R'
# Shop orders

`orders.py` creates orders; the checkout form is its only caller. A guest order has no email. `receipt.py` prints the receipt of an order, and `mailer.py` mails it: the checkout calls `send_receipt` after every order.

`batch.py` prints the receipts of the day. Cron starts it once a night, at 02:00, and nobody starts it by hand: after a crash, the run of the next night prints both days.

`data/orders-export.csv` is last month's export of the production orders table: the real data. The shop takes about 300 orders a day.

Tests: `python3 -m unittest tests.test_receipt`.
R
cat > orders.py <<'P'
def create_order(customer, lines, email=None):
    """Create an order. The checkout form calls this; nothing else writes an order. A guest order has no email."""
    if not lines:
        raise ValueError("an order needs a line")
    return {"customer": customer, "email": email, "lines": lines, "currency": "USD"}
P
cat > receipt.py <<'P'
def receipt_total(order):
    return round(sum(line["price"] * line["qty"] for line in order["lines"]), 2)


def receipt_text(order):
    return f"Total: {receipt_total(order):.2f}"
P
cat > mailer.py <<'P'
from receipt import receipt_text

OUTBOX = []


def send_receipt(order):
    """Mail the receipt of an order. The checkout calls this after every order."""
    to = order["email"].strip().lower()
    OUTBOX.append((to, receipt_text(order)))
P
cat > batch.py <<'P'
from receipt import receipt_text


def print_batch(orders, out):
    for order in orders:
        out.write(receipt_text(order) + "\n")
P
mkdir -p data tests
python3 - <<'P'
import random
random.seed(7)
rows = ["id,email,lines,total"]
for i in range(1, 401):
    email = random.choice(["", "", f"c{i}@example.com", f"c{i}@example.com", f"c{i}@example.com"])
    rows.append(f"{i},{email},{random.choice([1, 1, 2, 3])},{round(random.uniform(20, 200), 2)}")
open("data/orders-export.csv", "w").write("\n".join(rows) + "\n")
P
: > tests/__init__.py
cat > tests/test_receipt.py <<'P'
import unittest

from orders import create_order
from receipt import receipt_text


class ReceiptTest(unittest.TestCase):
    def test_text(self):
        order = create_order("ann", [{"price": 30.0, "qty": 1}], email="ann@example.com")
        self.assertEqual(receipt_text(order), "Total: 30.00")
P
printf '__pycache__/\nbatch.lock\n' >> .git/info/exclude
git add -A && git_q commit -qm 'orders, receipt, mailer and the nightly batch'
cat > receipt.py <<'P'
def receipt_total(order):
    return round(sum(line["price"] * line["qty"] for line in order["lines"]), 2)


def receipt_text(order):
    """The shop sells in USD only."""
    return f"Total: ${receipt_total(order):.2f}"
P
cat > batch.py <<'P'
import os

from receipt import receipt_text

LOCK = "batch.lock"


def _owner():
    try:
        with open(LOCK) as f:
            return int(f.read())
    except (OSError, ValueError):
        return None


def _alive(pid):
    try:
        os.kill(pid, 0)
    except ProcessLookupError:
        return False
    except OSError:
        return True
    return True


def take_lock():
    """One batch at a time. A lock whose owner is dead is stale: remove it and go on."""
    if os.path.exists(LOCK):
        pid = _owner()
        if pid is not None and _alive(pid):
            raise RuntimeError("a batch is running")
        os.remove(LOCK)
    fd = os.open(LOCK, os.O_CREAT | os.O_EXCL | os.O_WRONLY)
    with os.fdopen(fd, "w") as f:
        f.write(str(os.getpid()))


def print_batch(orders, out):
    take_lock()
    try:
        for order in orders:
            out.write(receipt_text(order) + "\n")
    finally:
        os.remove(LOCK)
P
cat > tests/test_receipt.py <<'P'
import io
import os
import unittest

import batch
from orders import create_order
from receipt import receipt_text


class ReceiptTest(unittest.TestCase):
    def test_text(self):
        order = create_order("ann", [{"price": 30.0, "qty": 1}], email="ann@example.com")
        self.assertEqual(receipt_text(order), "Total: $30.00")


class BatchLockTest(unittest.TestCase):
    def tearDown(self):
        if os.path.exists(batch.LOCK):
            os.remove(batch.LOCK)

    def test_second_batch_stops(self):
        batch.take_lock()
        with self.assertRaises(RuntimeError):
            batch.print_batch([], io.StringIO())

    def test_stale_lock_is_removed(self):
        with open(batch.LOCK, "w") as f:
            f.write("999999")
        out = io.StringIO()
        batch.print_batch([create_order("ann", [{"price": 30.0, "qty": 1}])], out)
        self.assertEqual(out.getvalue(), "Total: $30.00\n")
        self.assertFalse(os.path.exists(batch.LOCK))
P
git add -A && git_q commit -qm 'receipt: a dollar sign; batch: one run at a time'
s=.cookbook/dishes/batch-lock; mkdir -p "$s/evidence"
echo 'python3 -m unittest tests.test_receipt: Ran 3 tests, OK' > "$s/evidence/symbol-saute.txt"
echo 'python3 -m unittest tests.test_receipt: Ran 3 tests, OK' > "$s/evidence/lock-saute.txt"
cat > "$s/brief.md" <<'B'
# Brief: batch-lock
## Goal
The receipt shows a dollar sign, and one nightly batch runs at a time.
## Decisions
- The receipt total carries a dollar sign: the shop sells in USD only.
- The batch takes a lock file. A lock whose owner is dead is stale: the batch removes it and goes on.
## Done-checks
- `python3 -m unittest tests.test_receipt` passes.
- The receipt of an order reads `Total: $<amount>`.
- A second batch stops while the first one runs.
## Contested shape: no
## Open facts
None.
B
cat > "$s/recipe.md" <<'R'
# Recipe: batch-lock
## Problem
The receipt shows no currency, and two batches can print the same receipts.
## Usage
`receipt_text(order)` returns `Total: $<amount>`. `print_batch(orders, out)` takes the lock, prints and removes the lock.
## Shape
`receipt.py`: the dollar sign in `receipt_text`. `batch.py`: `take_lock()` writes the PID to `batch.lock`; a lock of a dead PID is removed.
## Units
| id | change | check | depends on | parallel |
|---|---|---|---|---|
| symbol | the dollar sign in receipt_text and its test | `python3 -m unittest tests.test_receipt` passes | none | no |
| lock | take_lock in batch.py and its two tests: a second batch stops; a stale lock is removed | `python3 -m unittest tests.test_receipt` passes | symbol | no |
## Taste
- surface: `receipt_text(order)` and `print_batch(orders, out)`
- judgement checks: none
- mutating checks: none
- live checks: none
## Out of scope
Tax, refunds.
## Choice
One sketch.
R
cat > "$s/ledger.md" <<'L'
# batch-lock
ask: a dollar sign on the receipt, and one nightly batch at a time
meal: none
worktree: none
phase: taste
size: standard, done-check clear, two units, reach one module, no risk, shape settled
size changes:
overlays: missing
gates: brief 2026-11-10, recipe 2026-11-10

| unit | check | parallel | status | fails | evidence |
|---|---|---|---|---|---|
| symbol | `python3 -m unittest tests.test_receipt` passes | no | pass | 0 | evidence/symbol-saute.txt |
| lock | `python3 -m unittest tests.test_receipt` passes | no | pass | 0 | evidence/lock-saute.txt |

events:
- 2026-11-10: saute plan: one group, serial in the main agent.
- 2026-11-10: saute done; taste: the verifier reviews the diff.
L
