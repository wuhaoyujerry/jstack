# One workflow tag in two tasks of one repo. The failure reads as generic, and no skill text covers it.
# An overlay applies to that repo. prompt2.txt gives the approval.
mkdir -p "$ROOT/overlays"
cat > "$ROOT/overlays/review-log.md" <<'L'
2026-10-02 | shop-api | add-export | workflow | brief-too-long | the brief repeated the ask in three sections | .jstack/add-export/brief.md | open
2026-10-20 | shop-api | fix-rounding | workflow | brief-too-long | the brief restated the ask under every heading | .jstack/fix-rounding/brief.md | open
L
: > "$ROOT/overlays/sizing-log.md"
printf '# Shop overlay\n\nApplies to the repo `shop-api`.\n' > "$ROOT/overlays/shop.md"
cp "$ROOT/overlays/shop.md" "$W/overlay-before"
