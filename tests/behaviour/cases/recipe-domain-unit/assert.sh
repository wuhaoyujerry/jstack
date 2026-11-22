. "$(dirname "$0")/../../lib.sh"
agent_ended
r=.cookbook/dishes/fetch-retry/recipe.md
[ -f "$r" ] || fail "no recipe"
# Scenario handoff-linked. The session in the dish worktree finds the cookbook in the main checkout and cooks on from the brief gate:
# the recipe above is written there. It makes no second cookbook, and it hands the dish to no other worktree.
[ ! -e "$W/wt/fetch-retry/.cookbook" ] || fail "a second cookbook in the dish worktree"
lacks "$ORCA_LOG" '--name fetch-retry( |$)'
# One unit of the recipe carries the brief's term to the root glossary and its ADR decision to docs/adr/.
row="$(sed -n '/^## Units/,/^## Taste/p' "$r" | grep -E '^\|' | grep -F 'GLOSSARY.md' | grep -F 'docs/adr/')"
[ -n "$row" ] || fail "no unit names both GLOSSARY.md and docs/adr/: $(sed -n '/^## Units/,/^## Taste/p' "$r" | grep -E '^\|' | cut -c1-160 | tr '\n' ' ')"
[ "$(printf '%s\n' "$row" | wc -l)" -eq 1 ] || fail "want one domain unit, got $(printf '%s\n' "$row" | wc -l)"
# The unit also sets Git's union merge for the glossary, so that dishes built in parallel both merge.
sed -n '/^## Units/,/^## Taste/p' "$r" | grep -Fq 'merge=union' || fail "no unit sets merge=union for the glossary"
# The main checkout gets neither file: they are committed with the dish, in its worktree.
clean_tree "$REPO"; clean_tree "$ROOT"
