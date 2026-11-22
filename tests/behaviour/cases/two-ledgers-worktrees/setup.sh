# The two-ledgers fixture after each dish was handed off: each ledger names its own dish worktree, and the session is in the main checkout.
. "$(dirname "$0")/../two-ledgers/setup.sh"
base="$(cd "$W" && pwd -P)/wt"
for slug in fetch-retry retry-fetch-client; do
  git worktree add -q -b "$slug" "$base/$slug"
  l=".cookbook/dishes/$slug/ledger.md"
  awk -v w="$base/$slug" '{ print } /^ask:/ { print "meal: none"; print "worktree: " w }' "$l" > "$l.new" && mv "$l.new" "$l"
done
rm -rf "$W/cookbook-before" && cp -R .cookbook "$W/cookbook-before"
