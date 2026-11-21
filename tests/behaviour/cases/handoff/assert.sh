. "$(dirname "$0")/../../lib.sh"
agent_ended
l=.cookbook/dishes/fetch-retry/ledger.md
has "$l" '^gates: brief [0-9]'
# The main checkout hands the dish off: one worktree named for it, from the current branch, with its agent and a prompt that names the dish.
n="$(grep -cE -- '(^| )worktree create( |$)' "$ORCA_LOG")"
[ "$n" -eq 1 ] || fail "want one worktree create, got $n: $(cat "$ORCA_LOG")"
for w in '--name fetch-retry( |$)' '--agent pi( |$)' "--base-branch $(git branch --show-current)( |\$)" 'cooking/SKILL\.md' 'continue the dish fetch-retry'; do has "$ORCA_LOG" "$w"; done
# The ledger names the worktree. This session wrote no recipe and changed no source, here or there.
has "$l" '^worktree: .*wt/fetch-retry'
[ ! -e .cookbook/dishes/fetch-retry/recipe.md ] || fail "the main checkout wrote a recipe"
[ -z "$(worker_starts)" ] || fail "started a worker: $(worker_starts)"
clean_tree "$REPO"; clean_tree "$W/wt/fetch-retry"; clean_tree "$ROOT"
