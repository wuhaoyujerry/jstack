. "$(dirname "$0")/../../lib.sh"
agent_ended
b=.cookbook/dishes/fetch-retry/brief.md
# The reply names the ADR that the decision contradicts and asks the user which holds: as a question, or as answers to choose
# from with the recommended one marked.
has "$OUT" '0001|standard-library-only'
grep -Eq '\?|[Rr]ecommend' "$OUT" || fail "reply asks no question"
# The conflict is an open decision: the brief is not complete, its gate stays open and no source changed.
if sed -n '/^## Done-checks/,/^## [^D]/p' "$b" | grep -Eq '^ *[-*] *[^ <]'; then fail "brief completed before the user answered"; fi
has .cookbook/dishes/fetch-retry/ledger.md '^gates: brief open, recipe open'
[ -z "$(git status --porcelain)" ] || fail "source changed in the idea phase"
clean_tree "$ROOT"
