. "$(dirname "$0")/../../lib.sh"
agent_ended
# Outside the home the session runs no step: no file and no log changes in either repo.
clean_tree "$REPO"; clean_tree "$ROOT"; same_file "$W/log-before" "$ROOT/overlays/review-log.md"
# It hands the ask to the home: a launch attempt that names it, or a prompt to paste that names it and the skill file.
# The run dir's name stands for the path, which the agent may print in its resolved form.
target="$(basename "$W")/jstack"
grep -qs -- "$target" "$ORCA_LOG" "$W/pi-nested.log" || { grep -q -- "$target" "$OUT" && grep -q -- 'skills/improve/SKILL.md' "$OUT"; } \
  || fail "no handoff names the home: $(tail -3 "$OUT")"
