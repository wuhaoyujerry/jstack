. "$(dirname "$0")/../../lib.sh"
agent_ended
log="$JSTACK_DATA/logs/review-log.md"; sess='2026-11-10T09-00-00-000Z_0199aaaa-0000-7000-8000-000000000001.jsonl'
# One new observation names the earlier session as its file and quotes the objection that no file records.
new="$(grep -F "$sess" "$log" | grep -v ' | repeat-approval | The agent asked again ')"
[ "$(printf '%s' "$new" | grep -c .)" = 1 ] || fail "want one new observation with the session file, got: ${new:-none}"
printf '%s\n' "$new" | awk -F' [|] ' -v s="$sess" '$(NF-1) != s { exit 1 }' || fail "file is not the session file's name: $new"
printf '%s\n' "$new" | grep -Eqi 'start a worker|one line|do it here' || fail "event lacks the user's words: $new"
# The objection that the log already records gets no second line.
[ "$(grep -Eic 'approv' "$log")" = 1 ] || fail "the recorded objection was logged again: $(grep -Ei 'approv' "$log" | tail -1)"
