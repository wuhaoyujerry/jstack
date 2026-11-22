# For setup.sh: the handoff-linked fixture, which several cases share.
# The handoff fixture after the handoff: the brief gate has its date, the ledger names the dish worktree, and the session starts in
# that worktree (the `cwd` file) with the prompt of the handoff.
wt="$(cd "$W" && pwd -P)/wt/fetch-retry"
export WORKTREE="$wt" BRIEF_GATE=2026-11-10 EVENT="- 2026-11-10 brief approved; handed off to $wt"
. "$(dirname "$0")/../handoff/setup.sh"
git worktree add -q -b fetch-retry "$wt"
