# Two workflow tags, each in two dishes: two changes that each edit skills/. The fake orca logs each judge launch.
mkdir -p "$JSTACK_DATA/logs"
cat > "$JSTACK_DATA/logs/review-log.md" <<'L'
2026-10-02 | shop-api | add-export | workflow | brief-too-long | the brief repeated the ask in three sections | .cookbook/add-export/brief.md | open
2026-10-20 | billing | fix-rounding | workflow | brief-too-long | the brief restated the ask under every heading | .cookbook/fix-rounding/brief.md | open
2026-10-05 | shop-api | add-import | workflow | evidence-unnamed | taste evidence files had names that did not show their unit | .cookbook/add-import/ledger.md | open
2026-10-22 | billing | fix-tax | workflow | evidence-unnamed | the verifier could not match an evidence file to its unit | .cookbook/fix-tax/ledger.md | open
L
: > "$JSTACK_DATA/logs/sizing-log.md"
. "$(dirname "$0")/../../fake-judge.sh"
