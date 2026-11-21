# Two dishes in two repos skipped an overlay's `after taste` hook, which cooking/SKILL.md already requires.
# The skipped step follows a ledger write, an event a runtime sees.
mkdir -p "$ROOT/logs"
cat > "$ROOT/logs/review-log.md" <<'L'
2026-10-02 | 5c1e0a77 | 91f3b2d4 | workflow | hook-skipped | taste ended and the agent ran review; an overlay that applies to the repo lists an `after taste` hook, and the ledger events hold no result for it | ledger.md | open
2026-10-20 | 8d2b4f10 | c07d6e18 | workflow | hook-skipped | the agent wrote `phase: review` to the ledger right after taste; the `after taste` hook of the overlay that applies never ran | ledger.md | open
L
: > "$ROOT/logs/sizing-log.md"
