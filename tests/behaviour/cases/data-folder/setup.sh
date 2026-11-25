# A trivial dish in taste: its one unit passed with evidence. The data folder holds an overlay that applies to every repo, with
# an after-taste hook. A folder overlays/ beside skills/ in the skills copy, where the overlays were once, holds another.
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
overlay() { # <directory> <hook file> <marker>
  mkdir -p "$1" "$(dirname "$2")"
  printf '# Marker\n\nWrite the line `hook ran` to `.cookbook/%s` at the repo root.\n' "$3" > "$2"
  cat > "$1/test.md" <<O
# Test overlay

Applies to every repo.

## Hooks

- after taste: \`$2\`. Write the marker.
O
}
overlay "$JSTACK_DATA/overlays" "$W/hook/SKILL.md" hook-ran.txt
overlay "$ROOT/overlays" "$W/old-hook/SKILL.md" old-hook-ran.txt
