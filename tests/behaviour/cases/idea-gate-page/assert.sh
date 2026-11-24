. "$(dirname "$0")/../../lib.sh"
agent_ended
d=.cookbook/dishes/fetch-retry; b="$d/brief.md"; p="$d/gate-page.html"; pic="$d/gate-picture.md"
sec() { awk -v h="## $1" '/^## /{on=($0==h); next} on && /[^ \t]/' "$b" | sed -E 's/^ *([-*]|[0-9]+[.)]) +//'; }
# The draft that the page keeps, as text.
src() { sed -n '/<textarea id="am-source"/,/<\/textarea>/p' "$p" | sed -e 's/&quot;/"/g' -e "s/&#39;/'/g" -e 's/&lt;/</g' -e 's/&gt;/>/g' -e 's/&amp;/\&/g'; }
# The picture is one block whose changed lines carry a marker: the parts of this dish connect.
[ -s "$pic" ] || fail "no picture file"
grep -Eq '^```(flow|state|tree|er|api)' "$pic" || fail "the picture is no diagram block: $(head -1 "$pic")"
[ "$(grep -c '^```' "$pic")" -eq 2 ] || fail "the picture holds more or less than one block"
grep -Eq '^[[:space:]]*[-+~] ' "$pic" || fail "no line of the picture carries a marker"
# The dish replaces the link of today from a failed request to its error, so the picture keeps a link marked removed.
grep -Eq '^[[:space:]]*- .*->' "$pic" || fail "the picture marks no link as removed"
# The page holds the goal, the picture and the brief's lines for the user, and nothing of the recipe sections.
[ -s "$p" ] || fail "no gate page"
goal="$(sec Goal | head -1)"; [ -n "$goal" ] || fail "the brief has no goal"
src | grep -Fq -- "subtitle: $goal" || fail "the page lacks the goal as its subtitle"
for h in 'What changes' 'What it does' 'How we check'; do src | grep -Fq -- "## $h" || fail "the page lacks the panel $h"; done
src | grep -Eq '^[[:space:]]*[-+~] ' || fail "the page lacks the picture"
sec 'What it does' | while IFS= read -r line; do src | grep -Fxq -- "- $line" || { echo "ASSERT: the page lacks the brief line: $line"; exit 1; }; done || exit 1
if src | grep -Eq 'Done-checks|Open facts|Contested|## Decisions|mock|urllib|time\.sleep|logging\.warning'; then fail "the page holds a recipe section or a mechanism: $(src | grep -E 'Done-checks|Open facts|Contested|## Decisions|mock|urllib|time\.sleep|logging\.warning' | head -1)"; fi
# Each line under "What stays the same" is plain: no code and no decision label. Whether it states what stays as it is, and
# does not read as its opposite under that title, is for a reader to decide at taste.
stays="$(src | awk '/^## /{on=($0=="## What stays the same"); next} on && /^- /')"
if printf '%s\n' "$stays" | grep -Eq '`|(^|[^A-Za-z])D[0-9]+([^A-Za-z0-9]|$)'; then fail "a line under What stays the same holds code or a decision label: $(printf '%s\n' "$stays" | grep -E '`|(^|[^A-Za-z])D[0-9]+([^A-Za-z0-9]|$)' | head -1)"; fi
# The gate reply is the whole message, three lines: the goal as the brief writes it, the link to the page and the ask for
# approval. Cooking recommends no split for this one-file dish, so nothing follows.
lines="$(grep '[^[:space:]]' "$OUT")"
[ "$(printf '%s\n' "$lines" | wc -l)" -eq 3 ] || fail "the reply has $(printf '%s\n' "$lines" | wc -l | tr -d ' ') lines, want the three of the gate reply: $(printf '%s\n' "$lines" | sed -n 4p | cut -c1-120)"
printf '%s\n' "$lines" | sed -n 1p | grep -Fq -- "$goal" || fail "the first line of the reply is not the goal: $(printf '%s\n' "$lines" | head -1 | cut -c1-120)"
printf '%s\n' "$lines" | sed -n 2p | grep -Eq 'file://[^ )]*gate-page\.html' || fail "the second line of the reply is not the link to the page"
printf '%s\n' "$lines" | sed -n 3p | grep -q '?' || fail "the third line of the reply asks for no approval"
lacks "$OUT" 'What it does|How we check|Done-checks|Open facts|Non-goals'
n="$(wc -w < "$OUT")"; [ "$n" -le 80 ] || fail "reply has $n words, want the gate reply and at most 80 words"
# The tool kept its state in the run directory, the gate waits for the user, and the idea phase changed no source.
[ -e "$W/am-home/state.json" ] || fail "the page tool left no state in the run directory"
has "$d/ledger.md" '^gates: brief open, recipe open'
[ -z "$(git status --porcelain)" ] || fail "source changed in the idea phase"
clean_tree "$ROOT"
