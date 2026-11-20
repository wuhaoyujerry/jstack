. "$(dirname "$0")/../../lib.sh"
agent_ended
l=.cookbook/fetch-retry/ledger.md
# The correction is on disk for review to read, the recipe follows it, and the gate stays open.
sed -n '/^events:/,$p' "$l" | grep -Eqi 'fetch_with_retry|correct' || fail "ledger events lack the user's correction"
has .cookbook/fetch-retry/recipe.md 'fetch_with_retry'
has "$l" '^gates: brief 2026-11-10, recipe open'
[ -z "$(git status --porcelain)" ] || fail "source changed before approval"
clean_tree "$ROOT"
