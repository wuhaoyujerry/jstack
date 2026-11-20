. "$(dirname "$0")/../../lib.sh"
agent_ended
has .jstack/hook-ran.txt 'hook ran'
sed -n '/^events:/,$p' .jstack/rename-parse/ledger.md | grep -qi 'hook' || fail "ledger events lack the hook result"
has .jstack/rename-parse/ledger.md '^phase: done'
# The hook runs when taste ends, before review writes its logs.
[ -f "$ROOT/logs/sizing-log.md" ] || fail "review did not run"
[ .jstack/hook-ran.txt -ot "$ROOT/logs/sizing-log.md" ] || fail "the hook ran after review"
clean_tree "$REPO"; clean_tree "$ROOT"; no_workers
