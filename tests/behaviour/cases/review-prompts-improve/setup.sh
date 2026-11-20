# The resume fixture, plus a review log where one tag already appears twice across two tasks.
. "$(dirname "$0")/../resume/setup.sh"
mkdir -p "$ROOT/logs"
cat > "$ROOT/logs/review-log.md" <<'L'
2026-10-02 | shop-api | add-export | workflow | recipe-gate-unclear | the recipe was shown but the stop for approval was missed | .jstack/add-export/ledger.md | open
2026-10-20 | billing | fix-rounding | workflow | recipe-gate-unclear | work started before the recipe was approved | .jstack/fix-rounding/ledger.md | open
L
: > "$ROOT/logs/sizing-log.md"
