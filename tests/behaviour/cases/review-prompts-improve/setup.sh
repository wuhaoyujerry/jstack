# The resume fixture, plus a review log where one tag already appears twice across two dishes.
. "$(dirname "$0")/../resume/setup.sh"
mkdir -p "$JSTACK_DATA/logs"
cat > "$JSTACK_DATA/logs/review-log.md" <<'L'
2026-10-02 | shop-api | add-export | workflow | recipe-gate-unclear | the recipe was shown but the stop for approval was missed | .cookbook/add-export/ledger.md | open
2026-10-20 | billing | fix-rounding | workflow | recipe-gate-unclear | work started before the recipe was approved | .cookbook/fix-rounding/ledger.md | open
L
: > "$JSTACK_DATA/logs/sizing-log.md"
