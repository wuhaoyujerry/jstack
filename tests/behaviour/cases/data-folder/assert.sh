. "$(dirname "$0")/../../lib.sh"
agent_ended
has .cookbook/hook-ran.txt 'hook ran'
[ ! -e .cookbook/old-hook-ran.txt ] || fail "a hook ran from the overlays folder beside the skills"
has .cookbook/dishes/rename-parse/ledger.md '^phase: done'
# Review keeps the logs and the task map in the data folder.
[ -f "$JSTACK_DATA/logs/sizing-log.md" ] || fail "the data folder lacks the sizing log"
[ -f "$JSTACK_DATA/overlays/tasks.txt" ] || fail "the data folder lacks the task map"
[ ! -e "$ROOT/logs" ] || fail "logs were written beside the skills"
[ ! -e "$ROOT/overlays/tasks.txt" ] || fail "the task map was written beside the skills"
clean_tree "$REPO"; clean_tree "$ROOT"; no_workers
