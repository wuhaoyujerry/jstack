. "$(dirname "$0")/../../lib.sh"
agent_ended
log="$ROOT/logs/review-log.md"
# No file is in reach and the event is too thin to act on: the line asks its machine for the detail, and the mark is pushed.
has "$log" 'slow-lookup .*\| needs-info [0-9][0-9/-]+ +[^ |]+'
pushed review-log.md 'slow-lookup .*\| needs-info '
[ -z "$(git -C "$ROOT" status --porcelain -- skills)" ] || fail "a skill file changed: $(git -C "$ROOT" status --porcelain -- skills | head -3)"
no_workers
