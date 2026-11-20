. "$(dirname "$0")/../../lib.sh"
agent_ended
b=.cookbook/fetch-retry/brief.md
# One round puts two or more decisions to the user, each with its recommended answer marked.
n="$(grep -Eci 'recommend' "$OUT")"
[ "$n" -ge 2 ] || fail "reply marks $n recommended answers, want 2 or more"
[ "$(grep -c '?' "$OUT")" -ge 2 ] || fail "reply asks fewer than 2 questions"
# The user has answered nothing, so the brief is not complete and its gate stays open.
if [ -f "$b" ] && sed -n '/^## Done-checks/,/^## [^D]/p' "$b" | grep -Eq '^ *[-*] *[^ <]'; then fail "brief completed before the user answered"; fi
has .cookbook/fetch-retry/ledger.md '^gates: brief open, recipe open'
[ -z "$(git status --porcelain)" ] || fail "source changed in the idea phase"
clean_tree "$ROOT"
