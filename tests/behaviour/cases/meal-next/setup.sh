# A meal of three dishes: the first is done, and the other two wait only for it, so both are ready and the table gives the order.
# DEP3 names another dependency for the third dish. WORK_BRANCH leaves the first dish's work on that branch, off the current one.
echo 'Cart tools.' > README.md
printf '__pycache__/\n.pytest_cache/\n' >> .git/info/exclude
git add -A && git_q commit -qm init
[ -z "${WORK_BRANCH:-}" ] || git checkout -q -b "$WORK_BRANCH"
printf 'def total(cart):\n    return sum(i["price"] * i["qty"] for i in cart)\n' > cart.py
printf 'from cart import total\n\ndef test_total():\n    assert total([{"price": 2, "qty": 3}]) == 6\n' > test_cart.py
git add -A && git_q commit -qm 'cart totals'
commit="$(git rev-parse --short HEAD)"
[ -z "${WORK_BRANCH:-}" ] || git checkout -q -
mkdir -p .cookbook/meals
cat > .cookbook/meals/checkout.md <<M
# Meal: checkout
goal: an operator can total a cart, export it as CSV and email a cart summary

## Shared decisions
- Standard library only.

## Dishes
| dish | depends on |
|---|---|
| cart-totals | none |
| cart-export | cart-totals |
| cart-email | ${DEP3:-cart-totals} |
M
ledger() { # <slug> <ask> <phase> <size> <gates> <unit row> <event>
  mkdir -p ".cookbook/$1"
  cat > ".cookbook/$1/ledger.md" <<L
# $1
ask: $2
meal: checkout
phase: $3
size: $4
size changes:
overlays: missing
gates: $5

| unit | check | parallel | status | fails | evidence |
|---|---|---|---|---|---|
$6
events:
- 2026-11-10 split from cart-totals into the meal checkout
$7
L
}
brief() { # <slug> <goal> <decision> <done-check>
  cat > ".cookbook/$1/brief.md" <<B
# Brief: $1
## Goal
$2
## Decisions
- Shared: \`.cookbook/meals/checkout.md\`.
- $3
## Non-goals
Other formats, other transports.
## Done-checks
- $4
## Contested shape: no
## Open facts
None.
B
}
ledger cart-totals 'total a cart' 'done' 'standard, done-check clear, one unit, reach public function, no risk, shape settled' \
  'brief 2026-11-10, recipe 2026-11-10' '| total | `python -m pytest test_cart.py` passes | no | pass | 0 | evidence/total-saute.txt |' \
  "- 2026-11-10 unit total: commit $commit${WORK_BRANCH:+ on branch $WORK_BRANCH}"
mkdir -p .cookbook/cart-totals/evidence && echo '1 passed' > .cookbook/cart-totals/evidence/total-saute.txt
ledger cart-export 'export a cart as CSV' size '' 'brief open, recipe open' '' ''
brief cart-export 'An operator can export a cart as CSV.' \
  'A new public function `export_csv(cart, path)` in a new module `export.py` writes the header `price,qty`, one row per item, and a last row with the total from `cart.total`.' \
  '`python -m pytest test_export.py` passes: a two-item cart gives the header, two rows and the total row.'
ledger cart-email 'email a cart summary' size '' 'brief open, recipe open' '' ''
brief cart-email 'An operator can email a summary of a cart.' \
  'A new public function `email_summary(cart, to)` in a new module `mailer.py` sends the item count and the total from `cart.total`.' \
  '`python -m pytest test_mailer.py` passes: the message to a stub SMTP server holds the item count and the total.'
cp -R .cookbook "$W/before"
