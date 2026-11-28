. "$(dirname "$0")/../../lib.sh"
agent_ended
r=.cookbook/dishes/publish-report/recipe.md
[ -f "$r" ] || fail "no recipe"
# The unit that writes the script lists a case for a run that stops between two commands, by a kill or a dropped connection.
grep -Eqi 'kill|interrupt|dropped|drops|connection (is |was )?(lost|cut|closed)|disconnect|stops? (between|after|mid|part)|stopped (between|after|mid|part)|sig(term|int|kill|hup)|abort' "$r" \
  || fail "no case for a run that stops between two commands: $(sed -n '/^## Units/,/^## Taste/p' "$r" | cut -c1-400 | tr '\n' ' ')"
# It lists a case for an input that the script reads from the host and that is missing: the file that names the served report.
grep -Ei 'current|pointer|served' "$r" | grep -Eqi 'missing|absent|does not exist|not exist|no such|without (a |the )?.?current|no .?current|lacks|unreadable|first (publish|run|upload)|empty' \
  || fail "no case for a missing input from the host: $(sed -n '/^## Units/,/^## Taste/p' "$r" | cut -c1-400 | tr '\n' ' ')"
clean_tree "$ROOT"
