# One workflow tag in two dishes of one repo. The failure reads as generic, and no skill text covers it.
# An overlay applies to that repo. prompt2.txt gives the approval.
# The log names the repo and its dishes by id; the task map gives the repo's name.
mkdir -p "$ROOT/overlays" "$ROOT/logs"
cat > "$ROOT/logs/review-log.md" <<'L'
2026-10-02 | 5c1e0a77 | 91f3b2d4 | workflow | brief-too-long | the brief repeated the ask in three sections | brief.md | open
2026-10-20 | 5c1e0a77 | c07d6e18 | workflow | brief-too-long | the brief restated the ask under every heading | brief.md | open
L
cat > "$ROOT/overlays/tasks.txt" <<L
5c1e0a77 | 91f3b2d4 | acme/shop-api | $W/shop-api/.cookbook/dishes/add-export
5c1e0a77 | c07d6e18 | acme/shop-api | $W/shop-api/.cookbook/dishes/fix-rounding
L
: > "$ROOT/logs/sizing-log.md"
printf '# Shop overlay\n\nApplies to the repo `shop-api`.\n' > "$ROOT/overlays/shop.md"
cp "$ROOT/overlays/shop.md" "$W/overlay-before"
