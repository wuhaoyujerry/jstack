# The handoff-linked fixture with the session in the main checkout. Only the `worktree` line of the ledger names the dish worktree:
# the events do not say where the dish went.
. "$(dirname "$0")/../handoff-linked/setup.sh"
l=.cookbook/dishes/fetch-retry/ledger.md
sed 's/; handed off to .*//' "$l" > "$l.new" && mv "$l.new" "$l"
cp -R .cookbook "$W/before"
