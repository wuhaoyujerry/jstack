. "$(dirname "$0")/../../lib.sh"
agent_ended
set -- .cookbook/*/ledger.md
[ "$#" -eq 1 ] && [ -f "$1" ] || fail "want one ledger, got: $*"
git check-ignore -q .cookbook/x || fail "Git does not ignore .cookbook/"
# The rule is in the repo's exclude file, so no tracked or new file changed.
clean_tree "$REPO"
