. "$(dirname "$0")/../../lib.sh"
agent_ended
set -- .cookbook/meals/*/meal.md
[ "$#" -eq 1 ] && [ -f "$1" ] || fail "want one meal file, got: $*"
meal="$1"; md="$(dirname "$meal")"
# The shared decision moves to the meal file, and the original dish still owns its ADR: the mark, the alternatives and the reason
# stay in that dish's brief, so that its recipe cuts the unit that commits the ADR.
has "$meal" '[Ss]tandard library'
b="$md/sync-export/brief.md"
[ -f "$b" ] || fail "the original dish is not in the meal folder"
has "$b" '[Ss]tandard library.*ADR'
has "$b" 'tenacity'
has "$b" 'package installer'
# One dish owns it: no other brief carries the mark.
n="$(grep -lE '[Ss]tandard library.*ADR' "$md"/*/brief.md | wc -l)"
[ "$n" -eq 1 ] || fail "$n briefs mark the shared decision ADR, want 1"
clean_tree "$REPO"; clean_tree "$ROOT"
