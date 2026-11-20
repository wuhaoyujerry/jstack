mkdir -p "$ROOT/logs"
cat > "$ROOT/logs/review-log.md" <<'L'
2026-10-02 | shop-api | add-export | workflow | brief-too-long | the brief repeated the ask in three sections | .cookbook/add-export/brief.md | open
L
: > "$ROOT/logs/sizing-log.md"
cp "$ROOT/logs/review-log.md" "$W/log-before"
