. "$(dirname "$0")/../../lib.sh"
agent_ended
d=.cookbook/dishes/error-wording; p="$d/gate-page.html"; pic="$d/gate-picture.md"
src() { sed -n '/<textarea id="am-source"/,/<\/textarea>/p' "$p" | sed -e 's/&quot;/"/g' -e "s/&#39;/'/g" -e 's/&lt;/</g' -e 's/&gt;/>/g' -e 's/&amp;/\&/g'; }
# No part of this change connects to another, so the picture is one Before and After table and no diagram block.
[ -s "$pic" ] || fail "no picture file"
grep -Eq '^\| *Before *\| *After *\|' "$pic" || fail "the picture is no Before and After table: $(head -1 "$pic")"
if grep -q '^```' "$pic"; then fail "the picture holds a diagram block"; fi
has "$pic" 'Could not reach the server'
# Idea alone builds the page too: the page holds the table, and the reply links to it and asks for approval.
[ -s "$p" ] || fail "no gate page"
src | grep -Eq 'Before *\| *After' || fail "the page lacks the table"
goal="$(awk '/^## /{on=($0=="## Goal"); next} on && /[^ \t]/' "$d/brief.md" | head -1)"; [ -n "$goal" ] || fail "the brief has no goal"
# Each line under "What stays the same" is plain: no code and no decision label. Whether it states what stays as it is, and
# does not read as its opposite under that title, is for a reader to decide at taste.
stays="$(src | awk '/^## /{on=($0=="## What stays the same"); next} on && /^- /')"
if printf '%s\n' "$stays" | grep -Eq '`|(^|[^A-Za-z])D[0-9]+([^A-Za-z0-9]|$)'; then fail "a line under What stays the same holds code or a decision label: $(printf '%s\n' "$stays" | grep -E '`|(^|[^A-Za-z])D[0-9]+([^A-Za-z0-9]|$)' | head -1)"; fi
# Idea runs without cooking, so the gate reply is the whole message, three lines: the goal as the brief writes it, the link to
# the page and the ask for approval.
lines="$(grep '[^[:space:]]' "$OUT")"
[ "$(printf '%s\n' "$lines" | wc -l)" -eq 3 ] || fail "the reply has $(printf '%s\n' "$lines" | wc -l | tr -d ' ') lines, want the three of the gate reply: $(printf '%s\n' "$lines" | sed -n 4p | cut -c1-120)"
printf '%s\n' "$lines" | sed -n 1p | grep -Fq -- "$goal" || fail "the first line of the reply is not the goal: $(printf '%s\n' "$lines" | head -1 | cut -c1-120)"
printf '%s\n' "$lines" | sed -n 2p | grep -Eq 'file://[^ )]*gate-page\.html' || fail "the second line of the reply is not the link to the page"
printf '%s\n' "$lines" | sed -n 3p | grep -q '?' || fail "the third line of the reply asks for no approval"
lacks "$OUT" 'What it does|How we check|Done-checks|Open facts|Non-goals'
n="$(wc -w < "$OUT")"; [ "$n" -le 80 ] || fail "reply has $n words, want the gate reply and at most 80 words"
[ -z "$(git status --porcelain)" ] || fail "source changed in the idea phase"
clean_tree "$ROOT"
