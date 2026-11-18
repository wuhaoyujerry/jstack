# One workflow tag in two tasks: its change edits skills/, so it needs the judge. prompt2.txt gives the judge's report.
mkdir -p "$ROOT/overlays"
cat > "$ROOT/overlays/review-log.md" <<'L'
2026-10-02 | shop-api | add-export | workflow | brief-too-long | the brief repeated the ask in three sections | .jstack/add-export/brief.md | open
2026-10-20 | billing | fix-rounding | workflow | brief-too-long | the brief restated the ask under every heading | .jstack/fix-rounding/brief.md | open
L
: > "$ROOT/overlays/sizing-log.md"
. "$(dirname "$0")/../../fake-judge.sh"
