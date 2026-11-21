. "$(dirname "$0")/../../lib.sh"
agent_ended
# The session in the home runs on the model and effort the improve text names: the launch attempt carries both,
# or the prompt to paste names both.
t="$(cat "$ORCA_LOG" "$W/pi-nested.log" "$OUT" 2>/dev/null)"
printf '%s' "$t" | grep -q -- 'claude-fable-5-2' || fail "the handoff names no model: $(tail -3 "$OUT")"
printf '%s' "$t" | grep -qw -- 'high' || fail "the handoff names no effort: $(tail -3 "$OUT")"
clean_tree "$REPO"; clean_tree "$ROOT"
