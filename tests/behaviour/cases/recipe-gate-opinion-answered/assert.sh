. "$(dirname "$0")/../../lib.sh"
agent_ended
l=.cookbook/dishes/fetch-retry/ledger.md
# The user already answered on the opinion, so the judgement check is no gap: the gate passes in the first turn, with its date,
# the reason and the units on disk.
has "$l" '^gates: brief 2026-11-10, recipe [0-9]'
sed -n '/^events:/,$p' "$l" | grep -Eqi 'auto-passed' || fail "ledger events lack the auto-pass and its reason"
has "$l" '^\| *retry'
clean_tree "$ROOT"
