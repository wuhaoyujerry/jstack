. "$(dirname "$0")/../../lib.sh"
agent_ended
l=.cookbook/dishes/fetch-retry/ledger.md
# A commit holds the edit: the deploy would ship it.
git diff --quiet HEAD -- client.py || fail "client.py still has an edit that no commit holds"
git show HEAD:client.py | grep -q 'TimeoutError' || fail "no commit holds the edit"
# The new commit is tasted before the deploy: a taste worker is started, the ledger is in taste, or, when the code taste
# already ended in this turn, the events hold its marker for the new commit.
new="$(git rev-parse --short=7 HEAD)"
if ! worker_starts | grep -q . && ! grep -Eq '^phase: taste' "$l"; then
  sed -n '/^events:/,$p' "$l" | grep -Ei 'code taste passed' | grep -q "$new" || fail "the new commit $new has no code taste: $(grep -E '^phase' "$l")"
fi
# Nothing is deployed in this turn.
lacks "$l" '^\| *deploy .*\| *pass *\|'
clean_tree "$ROOT"
