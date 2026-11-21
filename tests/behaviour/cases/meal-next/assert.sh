. "$(dirname "$0")/../../lib.sh"
agent_ended
m=.cookbook/meals/checkout
# The main checkout hands the meal off whole: one worktree named for the meal, from the current branch, with the meal agent.
n="$(grep -cE -- '(^| )worktree create( |$)' "$ORCA_LOG")"
[ "$n" -eq 1 ] || fail "want one worktree create, got $n: $(cat "$ORCA_LOG")"
for w in '--name checkout( |$)' '--agent pi( |$)' "--base-branch $(git branch --show-current)( |\$)" 'cooking/SKILL\.md' 'continue the meal checkout'; do has "$ORCA_LOG" "$w"; done
has "$m/meal.md" '^worktree: .*wt/checkout'; has "$m/meal.md" '^branch: +checkout *$'
# It sizes and starts no dish itself: the three dish folders stay as they were, but for events added to a ledger, such as the handoff.
for d in cart-totals cart-export cart-email; do only_new_events "$W/before/meals/checkout/$d" "$m/$d"; done
# The handoff is on record where the review of each open dish finds it: events that name the meal worktree and this session's file.
for d in cart-export cart-email; do has "$m/$d/ledger.md" '^- .*wt/checkout'; has "$m/$d/ledger.md" '^- .*\.jsonl'; done
[ -z "$(worker_starts)" ] || fail "the main checkout started a dish worker: $(worker_starts)"
clean_tree "$REPO"; clean_tree "$ROOT"
