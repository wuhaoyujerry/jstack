. "$(dirname "$0")/../../lib.sh"
agent_ended
has .cookbook/hook-ran.txt 'hook ran'
sed -n '/^events:/,$p' .cookbook/dishes/rename-parse/ledger.md | grep -qi 'hook' || fail "ledger events lack the hook result"
has .cookbook/dishes/rename-parse/ledger.md '^phase: done'
# The hook runs when taste ends, before review writes its logs.
[ -f "$JSTACK_DATA/logs/sizing-log.md" ] || fail "review did not run"
[ .cookbook/hook-ran.txt -ot "$JSTACK_DATA/logs/sizing-log.md" ] || fail "the hook ran after review"
clean_tree "$REPO"; clean_tree "$ROOT"; no_workers
