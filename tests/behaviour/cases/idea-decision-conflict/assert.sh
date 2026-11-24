. "$(dirname "$0")/../../lib.sh"
agent_ended
d=.cookbook/dishes/fetch-retry
# The reply names the two decisions that cannot both hold and asks the user which one stands: as a question, or as answers to
# choose from with the recommended one marked.
has "$OUT" 'D7|[Ss]tatus'
has "$OUT" 'D6|D2|D1|[Ww]ait|[Rr]etr|opt'
has "$OUT" '[Ww]hich|[Cc]onflict|[Cc]ontradict|both hold|both be true|[Ii]ncompatible'
grep -Eq '\?|[Rr]ecommend' "$OUT" || fail "reply asks no question"
# The conflict is an open decision: the brief is not complete, no gate page exists, the gate stays open and no source changed.
if sed -n '/^## Done-checks/,/^## [^D]/p' "$d/brief.md" | grep -Eq '^ *([-*]|[0-9]+[.)]) *[^ <]'; then fail "brief completed before the user answered"; fi
[ ! -e "$d/gate-page.html" ] || fail "built a gate page before the user answered"
has "$d/ledger.md" '^gates: brief open, recipe open'
[ -z "$(git status --porcelain)" ] || fail "source changed in the idea phase"
clean_tree "$ROOT"
