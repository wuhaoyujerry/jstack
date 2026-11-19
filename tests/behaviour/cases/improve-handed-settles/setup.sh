# An earlier run handed a change to this repo, and a session here has made it since. No observation is open.
mkdir -p tools
printf 'check:\n\tpython -m pytest tests\n' > tools/Makefile
printf '# shop-api\n\nRun the tests with `make -C tools check`.\n' > AGENTS.md
git add -A && git_q commit -qm 'name the test command'
mkdir -p "$ROOT/overlays"
cat > "$ROOT/overlays/review-log.md" <<L
2026-10-02 | $REPO | add-export | navigation | test-command-hidden | the test command took 14 searches to find; it is make -C tools check | $REPO/.jstack/add-export/evidence/nav.txt | handed 2026-10-05 $REPO/AGENTS.md
L
: > "$ROOT/overlays/sizing-log.md"
