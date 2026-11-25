# One navigation observation from another machine: the task map lacks its task, and its event does not say which fact was slow to find.
mkdir -p "$JSTACK_DATA/logs"
cat > "$JSTACK_DATA/logs/review-log.md" <<'L'
2026-10-02 | 5c1e0a77 | 91f3b2d4 | navigation | slow-lookup | a fact took long to find | evidence/nav.txt | open
L
: > "$JSTACK_DATA/logs/sizing-log.md"
