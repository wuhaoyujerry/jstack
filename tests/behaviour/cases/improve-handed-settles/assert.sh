. "$(dirname "$0")/../../lib.sh"
agent_ended
log="$ROOT/logs/review-log.md"
# The file holds the change, so the handed observation is settled as applied; its date and file stay.
has "$log" 'test-command-hidden .*\| applied 2026-10-05 +[^ |]*AGENTS\.md'
lacks "$log" '\| handed '
# The run proposes no change and still ends with a push of the logs.
pushed review-log.md 'test-command-hidden .*\| applied 2026-10-05'
clean_tree "$REPO"; clean_tree "$ROOT"
