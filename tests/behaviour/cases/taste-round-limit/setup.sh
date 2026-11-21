# A trivial dish in its second taste. The first taste returned work to saute, and the unit fix-main fixed it.
# The second taste found a defect inside that fix; the ledger holds no event for it yet.
echo 'def parse_line(s): return s.strip()' > util.py
printf 'from util import parse_line\nprint(parse_line)\n' > main.py
printf 'grep -q "def parse_line" util.py\n' > check.sh
git add -A && git_q commit -qm 'rename _parse to parse_line'
cp main.py "$W/main-before"
mkdir -p .cookbook/dishes/rename-parse/evidence
echo 'sh check.sh: exit 0' > .cookbook/dishes/rename-parse/evidence/rename-saute.txt
echo 'python3 main.py: exit 0' > .cookbook/dishes/rename-parse/evidence/fix-main-saute.txt
cat > .cookbook/dishes/rename-parse/evidence/main-taste.txt <<'E'
$ python3 main.py
<function parse_line at 0x1029d4ae0>
expected output: a
E
cat > .cookbook/dishes/rename-parse/taste.md <<'T'
| check | state | evidence | reason |
|---|---|---|---|
| sh check.sh | pass | evidence/rename-saute.txt | |
| python3 main.py prints `a` | fail | evidence/main-taste.txt | prints the function object: fix-main dropped the call |
T
cat > .cookbook/dishes/rename-parse/ledger.md <<'L'
# rename-parse
ask: rename the private function _parse to parse_line in util.py; main.py still prints `a`
meal: none
phase: taste
size: trivial, done-check clear, one unit, no reach, no risk, shape clear
size changes:
gates: brief open, recipe open

| unit | check | parallel | status | fails | evidence |
|---|---|---|---|---|---|
| rename | sh check.sh | no | pass | 0 | evidence/rename-saute.txt |
| fix-main | python3 main.py | no | pass | 0 | evidence/fix-main-saute.txt |

events:
- 2026-10-01 return from taste: main.py still imported `_parse`; added unit fix-main and returned to saute
- 2026-10-01 fix-main passed; saute done, taste runs again
L
