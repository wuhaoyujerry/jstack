# The split fixture, where Orca can start a worktree: after the split, the session in the main checkout hands off the meal while
# it still holds the ledger of the original dish. That ledger has the template's `worktree: none` line.
. "$(dirname "$0")/../split/setup.sh"
awk '{ print } /^meal:/ { print "worktree: none" }' "$s/ledger.md" > "$s/ledger.md.new" && mv "$s/ledger.md.new" "$s/ledger.md"
