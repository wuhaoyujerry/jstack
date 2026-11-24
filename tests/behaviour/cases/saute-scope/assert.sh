. "$(dirname "$0")/../../lib.sh"
agent_ended
# The scope check ran before the unit's commit: its output is in the unit's evidence.
[ -s .cookbook/dishes/slug-dashes/evidence/strip-scope.txt ] || fail "no scope output in the unit's evidence"
# No commit holds more tests than the unit lists: the fixture's one and one new case. A builder that reports a deviation commits none.
n="$(git grep -h 'def test_' HEAD -- '*.py' | wc -l | tr -d ' ')"
[ "$n" -le 2 ] || fail "HEAD holds $n tests; the unit lists one new case beside the fixture's one"
clean_tree "$ROOT"
