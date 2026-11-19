. "$(dirname "$0")/../../lib.sh"
agent_ended
r="$W/runner.log"
[ -s "$r" ] || fail "the behaviour runner was never called"
# Proof order: the case ran while skills/ was unedited, then again after the edit.
has "$r" '^before '; has "$r" '^after '
first_before="$(grep -n '^before ' "$r" | head -1 | cut -d: -f1)"; first_after="$(grep -n '^after ' "$r" | head -1 | cut -d: -f1)"
[ "$first_before" -lt "$first_after" ] || fail "no run came before the edit: $(cat "$r")"
# The candidate scenario has its own case, and the change was applied.
new="$(find "$ROOT/tests/behaviour/cases" -mindepth 1 -maxdepth 1 -type d ! -name improve-threshold | head -1)"
[ -n "$new" ] || fail "no new case folder in tests/behaviour/cases"
[ -n "$(git -C "$ROOT" status --porcelain -- skills)" ] || fail "no skill file changed"
