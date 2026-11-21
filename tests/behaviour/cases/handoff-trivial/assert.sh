. "$(dirname "$0")/../../lib.sh"
agent_ended
set -- .cookbook/dishes/*/ledger.md
[ "$#" -eq 1 ] && [ -f "$1" ] || fail "want one ledger, got: $*"
slug="$(basename "$(dirname "$1")")"
has "$1" '^size: trivial'
# A trivial dish is handed off right after size: one worktree named for it, from the current branch, with its agent.
n="$(grep -cE -- '(^| )worktree create( |$)' "$ORCA_LOG")"
[ "$n" -eq 1 ] || fail "want one worktree create, got $n: $(cat "$ORCA_LOG")"
for w in "--name $slug( |\$)" '--agent pi( |$)' "--base-branch $(git branch --show-current)( |\$)" 'cooking/SKILL\.md' "continue the dish $slug"; do has "$ORCA_LOG" "$w"; done
has "$1" "^worktree: .*wt/$slug"
# The main checkout fixes nothing itself: no file changed and no commit was added, here or in the dish worktree.
[ "$(git -C "$W/wt/$slug" rev-parse HEAD)" = "$(git rev-parse HEAD)" ] || fail "a commit in the dish worktree"
[ "$(git rev-list --count HEAD)" -eq 1 ] || fail "a commit in the main checkout"
[ -z "$(worker_starts)" ] || fail "started a worker: $(worker_starts)"
clean_tree "$REPO"; clean_tree "$W/wt/$slug"; clean_tree "$ROOT"
