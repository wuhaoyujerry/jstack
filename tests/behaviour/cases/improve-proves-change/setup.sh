# One workflow tag in two tasks of two repos: its change edits skills/. The skills copy gets a stand-in for the behaviour
# runner, which records each call and whether skills/ was edited yet: a case fails before the edit and passes after.
# prompt2.txt gives the judge's report and the approval.
mkdir -p "$ROOT/overlays" "$ROOT/tests/behaviour/cases/improve-threshold"
cat > "$ROOT/overlays/review-log.md" <<'L'
2026-10-02 | shop-api | add-export | workflow | brief-too-long | the brief repeated the ask in three sections | .jstack/add-export/brief.md | open
2026-10-20 | billing | fix-rounding | workflow | brief-too-long | the brief restated the ask under every heading | .jstack/fix-rounding/brief.md | open
L
: > "$ROOT/overlays/sizing-log.md"
cat > "$ROOT/tests/behaviour/run.sh" <<S
#!/bin/sh
# Usage: run.sh <case> ...   Env: RUNS per case and model (default 3).
if [ -z "\$(git -C "$ROOT" status --porcelain -- skills)" ]; then state=before; else state=after; fi
echo "\$state \${RUNS:-3} \$*" >> "$W/runner.log"
for c in "\$@"; do
  if [ "\$state" = before ]; then echo "FAIL \$c: its assertion failed"; else echo "PASS \$c"; fi
done
[ "\$state" = after ]
S
chmod +x "$ROOT/tests/behaviour/run.sh"
c="$ROOT/tests/behaviour/cases/improve-threshold"
printf 'mkdir -p "$ROOT/overlays"\necho "<one observation line>" > "$ROOT/overlays/review-log.md"\n' > "$c/setup.sh"
printf 'Read {{ROOT}}/skills/improve/SKILL.md and follow it. Ask: /improve\n' > "$c/prompt.txt"
printf '# Runs in the fixture repo after the agent ends; exits non-zero when the expected result is missing.\ngit -C "$ROOT" diff --quiet\n' > "$c/assert.sh"
(cd "$ROOT" && git add -A && git_q commit -qm 'add the behaviour runner')
. "$(dirname "$0")/../../fake-judge.sh"
