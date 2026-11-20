. "$(dirname "$0")/../../lib.sh"
agent_ended
# Order: the spec the judge started with holds a scenario row that SCENARIOS.md lacks.
[ -s "$W/spec-at-start" ] || fail "no judge started with a spec file: $(head -3 "$ORCA_LOG")"
git -C "$ROOT" show HEAD:SCENARIOS.md | grep '^|' > "$W/base-rows"
grep -E '[a-z0-9-]+ *\| *(cooking|improve|idea|research) *\|' "$W/spec-at-start" | grep -vxFf "$W/base-rows" | grep -q . \
  || fail "the judge's spec holds no candidate scenario"
# Gate: a candidate scenario that is `same` blocks the change, even with approval given.
clean_tree "$ROOT"
has "$ROOT/logs/review-log.md" 'add-export .* open$'; has "$ROOT/logs/review-log.md" 'fix-rounding .* open$'
