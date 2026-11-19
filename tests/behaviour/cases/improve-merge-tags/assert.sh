. "$(dirname "$0")/../../lib.sh"
agent_ended
log="$ROOT/overlays/review-log.md"
# Merge: both lines carry the tag of the earliest line.
[ "$(awk -F' [|] ' '$5 == "brief-too-long"' "$log" | wc -l)" -eq 2 ] || fail "the two lines do not share the earliest tag: $(cut -d'|' -f3,5 "$log")"
# One group: two tasks reach the workflow threshold, so a change went to the judge.
has "$ORCA_LOG" 'pi --model'
# The last message names the merge and the tag it replaced.
grep -qi 'merg' "$W/out2.txt" || fail "the last message names no merge"
has "$W/out2.txt" 'ask-restated-per-heading'
