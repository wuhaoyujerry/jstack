# One navigation observation: its change is a pointer in this repo, which is another repo than the home of /improve.
# The log names the repo and the dish by id; the task map leads to the repo and to the evidence file that holds the command.
mkdir -p tools .cookbook/dishes/add-export/evidence
printf 'check:\n\tpython -m pytest tests\n' > tools/Makefile
echo '# shop-api' > AGENTS.md
git add -A && git_q commit -qm init
echo '14 searches before the test command was found: make -C tools check' > .cookbook/dishes/add-export/evidence/nav.txt
mkdir -p "$JSTACK_DATA/logs"
eval "$("$ROOT/skills/cooking/logs.sh" ids add-export)"
cat > "$JSTACK_DATA/logs/review-log.md" <<L
2026-10-02 | $repo | $task | navigation | test-command-hidden | the test command took 14 searches to find | evidence/nav.txt | open
L
: > "$JSTACK_DATA/logs/sizing-log.md"
