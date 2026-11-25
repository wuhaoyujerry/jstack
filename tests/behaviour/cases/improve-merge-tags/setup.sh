# Two dishes logged one failure under two tags. Merged, the group has two dishes: its change edits skills/ and needs the judge.
mkdir -p "$JSTACK_DATA/logs"
cat > "$JSTACK_DATA/logs/review-log.md" <<'L'
2026-10-02 | shop-api | add-export | workflow | brief-too-long | the brief repeated the ask in three sections | .cookbook/add-export/brief.md | open
2026-10-20 | billing | fix-rounding | workflow | ask-restated-per-heading | the brief restated the ask under every heading | .cookbook/fix-rounding/brief.md | open
L
: > "$JSTACK_DATA/logs/sizing-log.md"
. "$(dirname "$0")/../../fake-judge.sh"
