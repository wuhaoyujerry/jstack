. "$(dirname "$0")/../../lib.sh"
agent_ended
# The user approved nothing: the copied skill and the recorded commit stay as they were.
clean_tree "$ROOT"
has "$ROOT/SOURCES.md" "$(cat "$W/base")"
has "$OUT" 'writing-for-agents'
