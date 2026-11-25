# Two dishes missed the Shape signal with the same verdict. prompt2.txt rejects the sizing change; prompt3.txt runs /improve again.
mkdir -p "$JSTACK_DATA/logs"
: > "$JSTACK_DATA/logs/review-log.md"
cat > "$JSTACK_DATA/logs/sizing-log.md" <<'L'
2026-10-02 | shop-api | add-export | predicted=standard | verdict=under | missed=Shape
2026-10-20 | billing | fix-rounding | predicted=standard | verdict=under | missed=Shape
L
. "$(dirname "$0")/../../fake-judge.sh"
