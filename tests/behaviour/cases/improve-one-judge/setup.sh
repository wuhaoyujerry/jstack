# Two workflow tags, each in two tasks: two changes that each edit skills/. The fake orca logs each judge launch.
mkdir -p "$ROOT/overlays"
cat > "$ROOT/overlays/review-log.md" <<'L'
2026-10-02 | shop-api | add-export | workflow | brief-too-long | the brief repeated the ask in three sections | .jstack/add-export/brief.md | open
2026-10-20 | billing | fix-rounding | workflow | brief-too-long | the brief restated the ask under every heading | .jstack/fix-rounding/brief.md | open
2026-10-05 | shop-api | add-import | workflow | evidence-unnamed | taste evidence files had names that did not show their unit | .jstack/add-import/ledger.md | open
2026-10-22 | billing | fix-tax | workflow | evidence-unnamed | the verifier could not match an evidence file to its unit | .jstack/fix-tax/ledger.md | open
L
: > "$ROOT/overlays/sizing-log.md"
. "$(dirname "$0")/../../fake-judge.sh"
