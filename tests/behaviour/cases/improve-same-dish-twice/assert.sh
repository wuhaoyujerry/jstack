. "$(dirname "$0")/../../lib.sh"
agent_ended
clean_tree "$ROOT"; same_file "$W/log-before" "$JSTACK_DATA/logs/review-log.md"; no_workers
has "$OUT" 'proposed: *`?0'
