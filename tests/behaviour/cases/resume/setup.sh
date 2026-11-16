# A trivial task stopped in taste: its one unit is `pass` but has no evidence file.
echo 'def parse_line(s): return s.strip()' > util.py
printf 'echo run >> .check-runs\ngrep -q "def parse_line" util.py\n' > check.sh
printf '.check-runs\n' >> .git/info/exclude
git add -A && git_q commit -qm 'rename _parse to parse_line'
mkdir -p .jstack/rename-parse
cat > .jstack/rename-parse/ledger.md <<'L'
# rename-parse
ask: rename the private function _parse to parse_line in util.py
phase: taste
size: trivial, done-check clear, one unit, no reach, no risk, shape clear
size changes:
gates: brief open, recipe open

| unit | check | parallel | status | fails | evidence |
|---|---|---|---|---|---|
| rename | sh check.sh | no | pass | 0 | evidence/rename-saute.txt |

events:
L
