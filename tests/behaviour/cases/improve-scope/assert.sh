. "$(dirname "$0")/../../lib.sh"
agent_ended
log="$ROOT/logs/review-log.md"
# One-repo evidence stays out of the generic text: no skill file changed and no judge started.
[ -z "$(git -C "$ROOT" status --porcelain -- skills)" ] || fail "a skill file changed: $(git -C "$ROOT" status --porcelain -- skills | head -3)"
lacks "$ORCA_LOG" 'pi --model'
# The rule went to the overlay that applies to the repo, and both observations name that file.
if cmp -s "$W/overlay-before" "$ROOT/overlays/shop.md"; then fail "the overlay gained no rule"; fi
[ "$(grep -Ec '\| applied [0-9][0-9/-]+ +[^ |]*overlays/shop\.md' "$log")" -eq 2 ] || fail "the two observations do not name the overlay: $(cut -d'|' -f3,8 "$log")"
