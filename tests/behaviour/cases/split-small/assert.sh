. "$(dirname "$0")/../../lib.sh"
agent_ended
# One part would be trivial, so the gate asks one thing: approve the brief. "Yes." then dates the gate and cuts nothing.
[ "$(cat "$W/cookbook-turn1")" = .cookbook/dishes/sync-rename/ledger.md ] || fail "the cookbook changed before the answer: $(tr '\n' ' ' < "$W/cookbook-turn1")"
# A behaviour run has no page tool: the reply opens with the line that says why there is no page.
grep '[^[:space:]]' "$OUT" | sed -n 1p | grep -q 'answer-me-with-html' || fail "the reply does not open with the reason for no page: $(grep '[^[:space:]]' "$OUT" | head -1 | cut -c1-120)"
# No split is recommended, so the reply ends with the ask for approval: the result of the split test is only in the ledger.
last="$(grep '[^[:space:]]' "$OUT" | tail -1)"; printf '%s\n' "$last" | grep -Eiq 'approv[^?]*\?[*_]*[[:space:]]*$' || fail "the reply does not end with the ask for approval: $(printf '%s\n' "$last" | cut -c1-120)"
[ ! -e .cookbook/meals ] || fail "a meal was written: $(ls .cookbook/meals)"
set -- .cookbook/dishes/*/ledger.md
[ "$#" -eq 1 ] || fail "want one ledger, got: $*"
has "$1" '^gates: brief [0-9]'
has "$1" '^meal: +none'
has .cookbook/dishes/sync-rename/brief.md 'test_sync'; has .cookbook/dishes/sync-rename/brief.md 'test_report'
clean_tree "$REPO"; clean_tree "$ROOT"
