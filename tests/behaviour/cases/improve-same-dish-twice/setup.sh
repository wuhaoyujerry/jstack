mkdir -p "$JSTACK_DATA/logs"
cat > "$JSTACK_DATA/logs/review-log.md" <<'L'
2026-10-02 | shop-api | add-export | workflow | brief-too-long | the brief repeated the ask in three sections | .cookbook/add-export/brief.md | open
2026-10-02 | shop-api | add-export | workflow | brief-too-long | the user cut the brief to half its length | .cookbook/add-export/ledger.md | open
L
: > "$JSTACK_DATA/logs/sizing-log.md"
cp "$JSTACK_DATA/logs/review-log.md" "$W/log-before"
