# Two dishes skipped the recipe gate, which cooking/SKILL.md already requires.
mkdir -p "$JSTACK_DATA/logs"
cat > "$JSTACK_DATA/logs/review-log.md" <<'L'
2026-10-02 | shop-api | add-export | workflow | recipe-gate-skipped | saute started before the user approved the recipe | .cookbook/add-export/ledger.md | open
2026-10-20 | billing | fix-rounding | workflow | recipe-gate-skipped | the recipe gate has no date but two units were built | .cookbook/fix-rounding/ledger.md | open
L
: > "$JSTACK_DATA/logs/sizing-log.md"
