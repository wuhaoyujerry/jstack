# Assertion helpers. Each prints the reason and exits 1 on failure.
# Available to assert.sh: $W (run dir), $ROOT (skills copy), $REPO (fixture repo, also cwd), $OUT (agent reply), $ORCA_LOG,
# $MODEL (the main agent's <model>:<effort>).

fail() { echo "ASSERT: $*"; exit 1; }

# The agent run itself must have ended normally.
agent_ended() { [ "$(cat "$W/pi.exit")" = 0 ] || fail "pi exit $(cat "$W/pi.exit"): $(tail -3 "$W/pi.err")"; }

same_file() { cmp -s "$1" "$2" || fail "$1 changed"; }
has() { grep -Eq -- "$2" "$1" 2>/dev/null || fail "$1 lacks /$2/"; }
lacks() { if grep -Eq -- "$2" "$1" 2>/dev/null; then fail "$1 has /$2/"; fi; }

# No tracked or new file changed in a Git repo (the fixture excludes .jstack/, the skills copy excludes overlays/).
clean_tree() { [ -z "$(git -C "$1" status --porcelain)" ] || fail "$1 changed: $(git -C "$1" status --porcelain | head -5)"; }
no_workers() { [ ! -s "$ORCA_LOG" ] || fail "tried to start a worker: $(head -2 "$ORCA_LOG")"; }
