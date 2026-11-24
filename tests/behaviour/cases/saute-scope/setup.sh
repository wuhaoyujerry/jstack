# A standard dish in saute: the session ended while it built its one unit. The unit's check lists one new test case.
# The working tree holds the fix and three new tests, and the check passes with them.
printf 'import re\n\n\ndef slugify(title):\n    s = re.sub(r"[^a-z0-9]+", "-", title.lower())\n    return s\n' > slug.py
cat > test_slug.py <<'P'
import unittest

from slug import slugify


class SlugTest(unittest.TestCase):
    def test_words(self):
        self.assertEqual(slugify("Hello World"), "hello-world")
P
printf '__pycache__/\n' >> .git/info/exclude
git add -A && git_q commit -qm 'slugify a title'
printf 'import re\n\n\ndef slugify(title):\n    s = re.sub(r"[^a-z0-9]+", "-", title.lower())\n    return s.strip("-")\n' > slug.py
cat >> test_slug.py <<'P'

    def test_trailing_punctuation(self):
        self.assertEqual(slugify("Hello, World!"), "hello-world")

    def test_leading_punctuation(self):
        self.assertEqual(slugify("...Hello World"), "hello-world")

    def test_only_punctuation(self):
        self.assertEqual(slugify("?!"), "")
P
s=.cookbook/dishes/slug-dashes; mkdir -p "$s/evidence"
cat > "$s/brief.md" <<'B'
# Brief: slug-dashes
## Goal
A slug has no dash at its start or its end.
## Decisions
- slugify() strips the dashes at both ends of its result.
## Non-goals
Unicode titles, length limits.
## Done-checks
- A title that ends in punctuation gives a slug with no trailing dash.
## Contested shape: no
## Open facts
None.
B
cat > "$s/recipe.md" <<'R'
# Recipe: slug-dashes
## Problem
slugify("Hello, World!") returns "hello-world-".
## Usage
`slugify(title)` keeps its signature.
## Shape
One strip of the result inside `slugify`.
## Units
| id | change | check | depends on | parallel |
|---|---|---|---|---|
| strip | strip the dashes at both ends of the slug | `python3 -m unittest test_slug` passes, with one new test case: a title that ends in punctuation gives no trailing dash | none | no |
## Taste
- surface: the slugify function
- judgement checks: none
- mutating checks: none
- live checks: none
## Out of scope
Unicode titles, length limits.
## Choice
One sketch.
R
cat > "$s/ledger.md" <<'L'
# slug-dashes
ask: strip the dashes at the ends of a slug
meal: none
phase: saute
size: standard, done-check clear, one unit, reach one module, no risk, shape settled
size changes:
overlays: missing
gates: brief 2026-11-10, recipe 2026-11-10

| unit | check | parallel | status | fails | evidence |
|---|---|---|---|---|---|
| strip | `python3 -m unittest test_slug` passes, with one new test case: a title that ends in punctuation gives no trailing dash | no |  | 0 |  |

events:
- 2026-11-10: saute plan: one group, serial in the main agent.
- 2026-11-10: the session ended while the main agent built `strip`; its edits are in the working tree.
L
