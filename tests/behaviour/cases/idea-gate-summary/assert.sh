. "$(dirname "$0")/../../lib.sh"
agent_ended
b=.cookbook/dishes/fetch-retry/brief.md
# The brief opens with the three sections for the user and closes with the section the user reads least.
heads="$(grep -E '^## ' "$b")"
[ "$(printf '%s\n' "$heads" | head -3 | tr '\n' '|')" = "## Goal|## What it does|## How we check|" ] || fail "brief opens with: $(printf '%s\n' "$heads" | head -3 | tr '\n' ' ')"
[ "$(printf '%s\n' "$heads" | tail -1)" = "## Decisions" ] || fail "last section is '$(printf '%s\n' "$heads" | tail -1)', want ## Decisions"
# A list item starts with a dash, a star or a number; a user section counts every line that is not blank.
item='^ *([-*]|[0-9]+[.)]) +'
sec() { awk -v h="## $1" '/^## /{on=($0==h); next} on' "$b"; }
sec Done-checks | grep -Eq "${item}[^ <]" || fail "brief has no done-check"
n="$(sec 'What it does' | grep -Ec '[^ ]')"; [ "$n" -ge 1 ] && [ "$n" -le 5 ] || fail "What it does has $n lines, want 1 to 5"
n="$(sec 'How we check' | grep -Ec '[^ ]')"; [ "$n" -ge 1 ] && [ "$n" -le 3 ] || fail "How we check has $n lines, want 1 to 3"
# The user sections are plain: no code, and 15 words or fewer a line.
user="$(sec Goal; sec 'What it does'; sec 'How we check')"
if printf '%s\n' "$user" | grep -Eq '`|mock|urllib|time\.sleep'; then fail "user sections hold code: $(printf '%s\n' "$user" | grep -E '`|mock|urllib|time\.sleep' | head -1)"; fi
long="$(printf '%s\n' "$user" | sed -E "s/$item//" | awk 'split($0,a," ")>15')"
[ -z "$long" ] || fail "a user line over 15 words: $(printf '%s\n' "$long" | head -1)"
# Each done-check and each decision is one sentence of 20 words or fewer; a label such as "D3.", "D3 Errors." or
# "D3 (2026-11-10):" at its start and a date in brackets at its end are not counted.
long="$(awk '/^## /{s=$0; next} s ~ /^## (Done-checks|Decisions)/ && /^ *([-*]|[0-9]+[.)]) /{l=$0; sub(/^ *([-*]|[0-9]+[.)]) +/,"",l); sub(/^D[0-9]+[^.:]*[.:] +/,"",l); sub(/ *\([^()]*\)\.?$/,"",l); if (split(l,a," ")>20) print l}' "$b")"
[ -z "$long" ] || fail "a line over 20 words: $(printf '%s\n' "$long" | head -1)"
# The reply is the gate summary: the user sections and the brief's path, without the sections for the recipe.
has "$OUT" 'brief\.md'
lacks "$OUT" 'Open facts|Done-checks|Non-goals|mock'
n="$(wc -w < "$OUT")"; [ "$n" -le 160 ] || fail "reply has $n words, want a gate summary and at most 160 words"
# The gate waits for the user.
has .cookbook/dishes/fetch-retry/ledger.md '^gates: brief open, recipe open'
[ -z "$(git status --porcelain)" ] || fail "source changed in the idea phase"
clean_tree "$ROOT"
