# Two tasks skipped the recipe gate, which cooking/SKILL.md already requires.
mkdir -p "$ROOT/logs"
cat > "$ROOT/logs/review-log.md" <<'L'
2026-10-02 | shop-api | add-export | workflow | recipe-gate-skipped | saute started before the user approved the recipe | .jstack/add-export/ledger.md | open
2026-10-20 | billing | fix-rounding | workflow | recipe-gate-skipped | the recipe gate has no date but two units were built | .jstack/fix-rounding/ledger.md | open
L
: > "$ROOT/logs/sizing-log.md"
