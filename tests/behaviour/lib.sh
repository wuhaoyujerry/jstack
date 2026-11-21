# Assertion helpers. Each prints the reason and exits 1 on failure.
# Available to assert.sh: $W (run dir), $ROOT (skills copy), $REPO (fixture repo, also cwd of assert.sh), $OUT (agent reply), $ORCA_LOG,
# $MODEL (the main agent's <model>:<effort>). $W/pi-nested.log holds each attempt of the agent to start pi itself.
# $ROOT/logs is a clone of the bare repo $W/logs.git, which receives the logs the agent pushes.

fail() { echo "ASSERT: $*"; exit 1; }

# The agent run itself must have ended normally.
agent_ended() { [ "$(cat "$W/pi.exit")" = 0 ] || fail "pi exit $(cat "$W/pi.exit"): $(tail -3 "$W/pi.err")"; }

same_file() { cmp -s "$1" "$2" || fail "$1 changed"; }
has() { grep -Eq -- "$2" "$1" 2>/dev/null || fail "$1 lacks /$2/"; }
lacks() { if grep -Eq -- "$2" "$1" 2>/dev/null; then fail "$1 has /$2/"; fi; }

# No tracked or new file changed in a Git repo (the fixture excludes .cookbook/, the skills copy excludes overlays/ and logs/).
clean_tree() { [ -z "$(git -C "$1" status --porcelain)" ] || fail "$1 changed: $(git -C "$1" status --porcelain | head -5)"; }
# The pushed copy of a log holds a line that matches.
pushed() { git -C "$W/logs.git" show "HEAD:$1" 2>/dev/null | grep -Eq -- "$2" || fail "the pushed $1 lacks /$2/"; }
# A dish folder is as it was in the copy <before>, but for events added to its ledger.
only_new_events() { # <before> <dish folder>
  diff -r -x ledger.md "$1" "$2" > /dev/null || fail "$2 changed"
  local extra; extra="$(diff "$1/ledger.md" "$2/ledger.md" | grep -E '^[<>]' | grep -Ev '^> - ')"
  [ -z "$extra" ] || fail "the ledger of $2 changed beyond new events: $extra"
}
# The worker starts in the log: one line for each `orca orchestration worker-start` call; a help call starts nothing.
worker_starts() { grep -E -- '(^| )orchestration worker-start( |$)' "$ORCA_LOG" 2>/dev/null | grep -Ev -- '(^| )(--help|-h)( |$)'; }
# The lines of the log that open a call of one orchestration verb, such as `ask` or `reply`.
orca_calls() { grep -E -- "(^| )orchestration $1( |\$)" "$ORCA_LOG" 2>/dev/null; }
# Only a call that starts a terminal, a worktree or a worker counts; a query such as `worktree list` starts nothing.
no_workers() { local s; s="$(grep -E -- '(^| )(terminal (create|split)|worktree create|orchestration (worker-start|dispatch|coordinator-start))( |$)' "$ORCA_LOG" 2>/dev/null | head -2)"; [ -z "$s" ] || fail "tried to start a worker: $s"; }
