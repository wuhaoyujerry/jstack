. "$(dirname "$0")/../../lib.sh"
agent_ended
[ -n "$(git -C "$REPO" status --porcelain; git -C "$REPO" log --oneline | sed 1d)" ] || fail "no change was applied in the repo"
# The log names the file the change edited, so a later recurrence can find it.
has "$ROOT/overlays/review-log.md" 'test-command-hidden .*\| applied [0-9][0-9/-]+ +[^ |]+'
