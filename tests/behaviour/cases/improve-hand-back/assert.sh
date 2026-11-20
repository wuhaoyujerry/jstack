. "$(dirname "$0")/../../lib.sh"
agent_ended
# The home session edits no file in the other repo: a session there applies the change.
clean_tree "$REPO"
# The handoff carries the change: a launch attempt that names the repo, or a prompt to paste in the reply to the approval.
# The run dir's name stands for the path, which the agent may print in its resolved form.
target="$(basename "$W")/repo"
grep -qs -- "$target" "$ORCA_LOG" "$W/pi-nested.log" || { grep -q -- 'make -C tools check' "$W/out2.txt" && grep -q -- 'AGENTS\.md' "$W/out2.txt"; } \
  || fail "no handoff carries the change: $(tail -3 "$W/out2.txt")"
# The log marks the change as handed and names the file it is to edit, so a later run can settle it.
has "$ROOT/logs/review-log.md" 'test-command-hidden .*\| handed [0-9][0-9/-]+ +[^ |]+'
