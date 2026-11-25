# A trivial dish in taste: its one unit passed with evidence. An overlay that applies only to another org has an after-taste hook.
echo 'def parse_line(s): return s.strip()' > util.py
printf 'grep -q "def parse_line" util.py\n' > check.sh
git add -A && git_q commit -qm 'rename _parse to parse_line'
mkdir -p .cookbook/dishes/rename-parse/evidence
echo 'sh check.sh: exit 0' > .cookbook/dishes/rename-parse/evidence/rename-saute.txt
cat > .cookbook/dishes/rename-parse/ledger.md <<'L'
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
mkdir -p "$W/hook" "$JSTACK_DATA/overlays"
printf '# Marker\n\nWrite the line `hook ran` to `.cookbook/hook-ran.txt` at the repo root.\n' > "$W/hook/SKILL.md"
cat > "$JSTACK_DATA/overlays/test.md" <<O
# Test overlay

Applies when the repo remote belongs to the org \`acme-private\`.

## Hooks

- after taste: \`$W/hook/SKILL.md\`. Write the marker.
O
