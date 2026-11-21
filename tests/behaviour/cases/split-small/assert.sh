. "$(dirname "$0")/../../lib.sh"
agent_ended
# One part would be trivial, so the gate asks one thing: approve the brief. "Yes." then dates the gate and cuts nothing.
[ "$(cat "$W/cookbook-turn1")" = .cookbook/dishes/sync-rename/ledger.md ] || fail "the cookbook changed before the answer: $(tr '\n' ' ' < "$W/cookbook-turn1")"
[ ! -e .cookbook/meals ] || fail "a meal was written: $(ls .cookbook/meals)"
set -- .cookbook/dishes/*/ledger.md
[ "$#" -eq 1 ] || fail "want one ledger, got: $*"
has "$1" '^gates: brief [0-9]'
has "$1" '^meal: +none'
has .cookbook/dishes/sync-rename/brief.md 'test_sync'; has .cookbook/dishes/sync-rename/brief.md 'test_report'
clean_tree "$REPO"; clean_tree "$ROOT"
