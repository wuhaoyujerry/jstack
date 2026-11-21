. "$(dirname "$0")/../../lib.sh"
agent_ended
# Turn 1 shows the brief gate and proposes the split: nothing is cut before the user answers.
[ "$(cat "$W/cookbook-turn1")" = .cookbook/dishes/sync-export/ledger.md ] || fail "the cookbook changed before the answer: $(tr '\n' ' ' < "$W/cookbook-turn1")"
[ ! -s "$W/status-turn1" ] || fail "source changed before the answer: $(cat "$W/status-turn1")"
has "$OUT" '[Ss]plit'
# Turn 2 approves: one meal folder that holds the meal file, the original dish's folder and one new dish.
set -- .cookbook/meals/*/meal.md
[ "$#" -eq 1 ] && [ -f "$1" ] || fail "want one meal file, got: $*"
meal="$1"; md="$(dirname "$meal")"
[ -f "$md/sync-export/ledger.md" ] || fail "the original dish is not in the meal folder"
[ ! -e .cookbook/dishes/sync-export ] || fail "the original dish's old folder remains"
set -- "$md"/*/ledger.md
[ "$#" -eq 2 ] || fail "want two ledgers, got: $*"
for l in "$@"; do
  d="$(dirname "$l")"; slug="$(basename "$d")"
  has "$l" '^meal: +[^ ]'; lacks "$l" '^meal: +none'
  has "$meal" "^\| *\`?$slug\`? *\|"
  sed -n '/^events:/,$p' "$l" | grep -qi split || fail "$l events lack the split"
  has "$d/brief.md" 'meals/'
  # The cut brief goes back to its gate; a new dish starts at size, with a brief and no recipe.
  has "$l" '^gates: brief open'
  [ "$slug" = sync-export ] || { has "$l" '^phase: size'; [ ! -e "$d/recipe.md" ] || fail "$slug got a recipe at the split"; }
done
# The shared decision moves to the meal file. Each done-check is in exactly one brief, and the two part.
has "$meal" '[Ss]tandard library'
in_brief() { grep -l -- "$1" "$md"/*/brief.md; }
for t in test_sync test_export; do
  [ "$(in_brief "$t" | wc -l)" -eq 1 ] || fail "$t is in $(in_brief "$t" | wc -l) briefs, want 1"
done
[ "$(in_brief test_sync)" != "$(in_brief test_export)" ] || fail "both done-checks are in one brief"
clean_tree "$REPO"; clean_tree "$ROOT"
