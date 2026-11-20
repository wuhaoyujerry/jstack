. "$(dirname "$0")/../../lib.sh"
agent_ended
log="$ROOT/logs/review-log.md"
# The file is in reach: the event gains the missing detail, and the observation is open to a change again.
lacks "$log" 'needs-info'
grep -Eqi 'slow-lookup \| [^|]*test command' "$log" || fail "the event lacks the detail of the file: $(cat "$log")"
clean_tree "$REPO"
