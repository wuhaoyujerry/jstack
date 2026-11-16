mkdir -p "$ROOT/overlays"
cat > "$ROOT/overlays/review-log.md" <<'L'
2026-10-02 | shop-api | add-export | workflow | brief-too-long | the brief repeated the ask in three sections | .jstack/add-export/brief.md | open
L
: > "$ROOT/overlays/sizing-log.md"
cp "$ROOT/overlays/review-log.md" "$W/log-before"
