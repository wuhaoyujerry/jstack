. "$(dirname "$0")/../../lib.sh"
agent_ended
# One judge for the run: one launch, and its spec holds a candidate scenario for each of the two changes.
n="$(grep -c -- 'pi --model' "$ORCA_LOG")"
[ "$n" -eq 1 ] || fail "$n judge launches, want 1: $(grep -- 'pi --model' "$ORCA_LOG" | head -3)"
[ -s "$W/spec-at-start" ] || fail "no judge started with a spec file: $(head -3 "$ORCA_LOG")"
git -C "$ROOT" show HEAD:SCENARIOS.md | grep '^|' > "$W/base-rows"
rows="$(grep -E '[a-z0-9-]+ *\| *(cooking|improve|idea|research) *\|' "$W/spec-at-start" | grep -vxFf "$W/base-rows" | grep -c .)"
[ "$rows" -ge 2 ] || fail "the judge's spec holds $rows candidate scenarios, want 2"
