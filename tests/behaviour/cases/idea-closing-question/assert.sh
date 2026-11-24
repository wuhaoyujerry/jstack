. "$(dirname "$0")/../../lib.sh"
agent_ended
b=.cookbook/dishes/fetch-retry/brief.md
closing='[Ww]hat haven.t I asked that I should have'
done_checks() { sed -n '/^## Done-checks/,/^## [^D]/p' "$1" | grep -Eq '^ *([-*]|[0-9]+[.)]) *[^ <]'; }
# Turn 1: the tree is empty, so the reply is the closing question. The brief is not complete before the answer.
has "$OUT" "$closing"
if done_checks "$W/brief-turn1"; then fail "brief completed before the user answered the closing question"; fi
# Turn 2: the answer names a choice that the user has not made. The agent asks it in a round, with its recommended answer
# marked, and does not ask the closing question again.
has "$W/out2.txt" '[Ss]econds|[Tt]imeout|[Tt]ime limit|how long'
grep -Eq '\?' "$W/out2.txt" || fail "turn 2 asks no question"
has "$W/out2.txt" '[Rr]ecommend'
lacks "$W/out2.txt" "$closing"
# Turn 3: the user made that choice and took the recommended answer to every other question of that round. The brief records
# the choice and holds one closing line; the closing question does not return.
lacks "$W/out3.txt" "$closing"
dec="$(sed -n '/^## Decisions/,$p' "$b")"
n="$(printf '%s\n' "$dec" | grep -Eci 'closing question')"
[ "$n" -eq 1 ] || fail "the decisions hold $n closing lines, want 1"
printf '%s\n' "$dec" | grep -Eqi 'five[ -]second|5[ -]second' || fail "the decisions lack the choice of turn 3"
# The gate waits for the user, and the idea phase changes no source.
has .cookbook/dishes/fetch-retry/ledger.md '^gates: brief open, recipe open'
[ -z "$(git status --porcelain)" ] || fail "source changed in the idea phase"
clean_tree "$ROOT"
