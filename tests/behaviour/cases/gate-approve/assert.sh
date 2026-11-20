. "$(dirname "$0")/../../lib.sh"
agent_ended
# Turn 1 shows the recipe and waits: gate still open, no unit copied, no source changed.
has "$W/ledger-turn1" '^gates: brief 2026-11-10, recipe open'
lacks "$W/ledger-turn1" '^\| *retry'
[ ! -s "$W/status-turn1" ] || fail "source changed before approval: $(cat "$W/status-turn1")"
# Turn 2 approves: the gate gets its date and the units reach the ledger.
has .cookbook/fetch-retry/ledger.md '^gates: brief 2026-11-10, recipe [0-9]'
has .cookbook/fetch-retry/ledger.md '^\| *retry'
clean_tree "$ROOT"
