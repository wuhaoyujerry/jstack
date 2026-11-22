. "$(dirname "$0")/../../lib.sh"
agent_ended
r=.cookbook/dishes/fetch-retry/recipe.md
[ -f "$r" ] || fail "no recipe"
units="$(sed -n '/^## Units/,/^## Taste/p' "$r" | grep -E '^\|')"
# The ids of the units whose row matches: the first cell of each, without code marks or bold.
ids_of() { printf '%s\n' "$units" | grep -Ei -- "$1" | awk -F'|' '{gsub(/[ `*]/, "", $2); print $2}' | tr '\n' ' '; }
msg="$(ids_of 'calm|plain|not technical|non-technical|wording')"
# The units that carry the page check and not the message.
page=; for i in $(ids_of '390|same line'); do case " $msg " in *" $i "*) ;; *) page="$page $i" ;; esac; done
# The judgement line of the Taste section, with the lines that continue it.
j="$(sed -n '/^## Taste/,$p' "$r" | awk 'tolower($0) ~ /judge?ment checks/ {on=1; print; next} on && /^(- |## )/ {exit} on')"
[ -n "$j" ] || fail "no judgement checks line"
marked() { printf '%s\n' "$j" | grep -Fqw -- "$1"; }
# The opinion on the wording is a judgement check: the line names a unit that carries it, or the check itself.
ok=; for i in $msg; do if marked "$i"; then ok=1; fi; done
if printf '%s\n' "$j" | grep -Eqi 'wording|message|calm|plain|tone'; then ok=1; fi
[ -n "$ok" ] || fail "the opinion check is not marked: $j"
# A reader must look at the page, but every reader decides it alike: the line names neither its unit nor its check. A sentence
# that says the page check is a fact, or is not a judgement check, marks nothing.
pos="$(printf '%s\n' "$j" | sed 's/\. /\n/g; s/;/\n/g' | grep -Eiv 'is not|are not|not a|fact|unmarked')"
for i in $page; do if printf '%s\n' "$pos" | grep -Fqw -- "$i"; then fail "the check of $i, which every reader decides alike, is marked: $j"; fi; done
if printf '%s\n' "$pos" | grep -Eqi '390|layout|same line|viewport'; then fail "the page check, which every reader decides alike, is marked: $j"; fi
# The user's decision leaves the wording to the builder: that is the answer on the opinion, so the gate passes without a question.
has .cookbook/dishes/fetch-retry/ledger.md '^gates: brief 2026-11-10, recipe [0-9]'
clean_tree "$REPO"; clean_tree "$ROOT"
