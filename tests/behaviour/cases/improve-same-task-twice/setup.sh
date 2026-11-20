mkdir -p "$ROOT/logs"
cat > "$ROOT/logs/review-log.md" <<'L'
2026-10-02 | shop-api | add-export | workflow | brief-too-long | the brief repeated the ask in three sections | .jstack/add-export/brief.md | open
2026-10-02 | shop-api | add-export | workflow | brief-too-long | the user cut the brief to half its length | .jstack/add-export/ledger.md | open
L
: > "$ROOT/logs/sizing-log.md"
cp "$ROOT/logs/review-log.md" "$W/log-before"
