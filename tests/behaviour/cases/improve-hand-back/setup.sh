# One navigation observation: its change is a pointer in this repo, which is another repo than the home of /improve.
mkdir -p tools .jstack/add-export/evidence
printf 'check:\n\tpython -m pytest tests\n' > tools/Makefile
echo '# shop-api' > AGENTS.md
git add -A && git_q commit -qm init
echo '14 searches before the test command was found: make -C tools check' > .jstack/add-export/evidence/nav.txt
mkdir -p "$ROOT/overlays"
cat > "$ROOT/overlays/review-log.md" <<L
2026-10-02 | $REPO | add-export | navigation | test-command-hidden | the test command took 14 searches to find; it is make -C tools check | $REPO/.jstack/add-export/evidence/nav.txt | open
L
: > "$ROOT/overlays/sizing-log.md"
