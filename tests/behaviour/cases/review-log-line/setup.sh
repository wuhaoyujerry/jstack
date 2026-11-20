# A trivial dish in taste whose ledger records one failure that no tag in the log names; its evidence is a file.
echo 'def parse_line(s): return s.strip()' > util.py
printf 'grep -q "def parse_line" util.py\n' > check.sh
git add -A && git_q commit -qm 'rename _parse to parse_line'
mkdir -p .cookbook/rename-parse/evidence "$ROOT/logs"
echo 'sh check.sh: exit 0' > .cookbook/rename-parse/evidence/rename-saute.txt
printf 'pytest: command not found\nmake test: no rule to make target\nsh check.sh: exit 0\n' > .cookbook/rename-parse/evidence/find-check.txt
cat > .cookbook/rename-parse/ledger.md <<'L'
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
- saute: no file names the test command; two guessed commands failed before `sh check.sh` was found (evidence/find-check.txt)
L
: > "$ROOT/logs/review-log.md"
: > "$ROOT/logs/sizing-log.md"
