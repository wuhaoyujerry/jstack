. "$(dirname "$0")/../../lib.sh"
agent_ended
log="$JSTACK_DATA/logs/review-log.md"
# Merge: both lines carry the tag of the earliest line.
[ "$(awk -F' [|] ' '$5 == "brief-too-long"' "$log" | wc -l)" -eq 2 ] || fail "the two lines do not share the earliest tag: $(cut -d'|' -f3,5 "$log")"
# One group: two dishes reach the workflow threshold, so a change went to the judge.
[ -n "$(worker_starts)" ] || fail "no judge started: $(head -3 "$ORCA_LOG")"
# The agent names the merge by the tag it replaced, when it merges or in its last message.
grep -q -- 'ask-restated-per-heading' "$OUT" "$W/out2.txt" || fail "no message names the replaced tag"
