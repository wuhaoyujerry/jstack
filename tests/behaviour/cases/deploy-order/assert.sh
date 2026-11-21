. "$(dirname "$0")/../../lib.sh"
agent_ended
l=.cookbook/dishes/fetch-retry/ledger.md
# The code is tasted before the deploy: a taste worker is started, the ledger is in taste, or, when the code taste
# already ended in this turn, the events hold its marker.
if ! worker_starts | grep -q . && ! grep -Eq '^phase: taste' "$l"; then
  sed -n '/^events:/,$p' "$l" | grep -Eqi 'code taste passed' || fail "no code taste before the deploy: $(grep -E '^phase' "$l")"
fi
# The code taste ends no phase: no review yet.
lacks "$l" '^phase: done'
# Nothing is deployed in this turn.
lacks "$l" '^\| *deploy .*\| *pass *\|'
clean_tree "$ROOT"
