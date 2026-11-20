# One workflow tag in two tasks: its change edits skills/, so improve starts a judge. The fake orca logs the launch.
mkdir -p "$ROOT/logs"
cat > "$ROOT/logs/review-log.md" <<'L'
2026-10-02 | shop-api | add-export | workflow | brief-too-long | the brief repeated the ask in three sections | .jstack/add-export/brief.md | open
2026-10-20 | billing | fix-rounding | workflow | brief-too-long | the brief restated the ask under every heading | .jstack/fix-rounding/brief.md | open
L
: > "$ROOT/logs/sizing-log.md"
. "$(dirname "$0")/../../fake-judge.sh"
