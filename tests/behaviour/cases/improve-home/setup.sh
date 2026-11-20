# The ask comes in a project repo, outside the working tree that holds the skills (the `from-repo` file).
# One navigation observation qualifies for a change, so a session that runs the steps here leaves a trace.
mkdir -p tools .cookbook/add-export/evidence
printf 'check:\n\tpython -m pytest tests\n' > tools/Makefile
echo '# shop-api' > AGENTS.md
git add -A && git_q commit -qm init
echo '14 searches before the test command was found: make -C tools check' > .cookbook/add-export/evidence/nav.txt
mkdir -p "$ROOT/logs"
eval "$("$ROOT/skills/cooking/logs.sh" ids add-export)"
cat > "$ROOT/logs/review-log.md" <<L
2026-10-02 | $repo | $task | navigation | test-command-hidden | the test command took 14 searches to find | evidence/nav.txt | open
L
: > "$ROOT/logs/sizing-log.md"
cp "$ROOT/logs/review-log.md" "$W/log-before"
