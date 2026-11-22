# A trivial dish stopped in review. Its ledger records a check that failed in a worktree with no interpreter link.
# Among the tags of the log, an applied line of another dish shows another symptom of that cause, in another category.
echo 'def parse_line(s): return s.strip()' > util.py
printf 'from util import parse_line\ndef test_parse_line(): assert parse_line(" a ") == "a"\n' > test_util.py
git add -A && git_q commit -qm 'rename _parse to parse_line'
s=.cookbook/dishes/rename-parse; mkdir -p "$s/evidence" "$ROOT/logs"
cat > "$s/evidence/rename-saute.txt" <<'E'
.venv/bin/python -m pytest test_util.py: .venv/bin/python: No such file or directory
.venv/bin/python -m pytest test_util.py: .venv/bin/python: No such file or directory
ln -s ../main/.venv .venv
.venv/bin/python -m pytest test_util.py: 1 passed
E
cat > "$s/taste.md" <<'T'
| check | state | evidence | reason |
|---|---|---|---|
| .venv/bin/python -m pytest test_util.py | pass | evidence/rename-saute.txt | the builder ran it |
T
cat > "$s/ledger.md" <<'L'
# rename-parse
ask: rename the private function _parse to parse_line in util.py
phase: review
size: trivial, done-check clear, one unit, no reach, no risk, shape clear
size changes:
gates: brief open, recipe open

| unit | check | parallel | status | fails | evidence |
|---|---|---|---|---|---|
| rename | .venv/bin/python -m pytest test_util.py | no | pass | 0 | evidence/rename-saute.txt |

events:
- saute: the dish worktree had no interpreter link; the test command failed twice until the agent linked the main checkout's environment (evidence/rename-saute.txt)
L
cat > "$ROOT/logs/review-log.md" <<'R'
2026-11-01 | 3c9d1e7a | 41aa07c2 | workflow | size-not-surfaced | The size moved from standard to large and was written only to the ledger; the user later had to ask which size applied. | ledger.md | open
2026-11-01 | 3c9d1e7a | 41aa07c2 | check | dirty-tree-deploy | The builder committed a renamed file without staging its edit; local checks ran on the working tree and passed, and the deploy failed its healthcheck. | ledger.md | applied 2026-11-02 skills/cooking/SKILL.md
2026-11-02 | 3c9d1e7a | 8b2f4a6c | workflow | time-estimate-unmeasured | The agent quoted 15 to 20 minutes for a judge round without checking earlier rounds; the report file times showed about 5 minutes per round. | "ok why it will take 15-20 mins?" | open
2026-11-02 | 3c9d1e7a | 8b2f4a6c | tool | lsp-worktree-env | The diagnostics extension reported missing-import blockers for every new file until the worktree's interpreter link was created, and kept repeating stale blockers after a live probe showed the files clean. | ledger.md | applied 2026-11-03 skills/cooking/SKILL.md
2026-11-02 | 3c9d1e7a | 8b2f4a6c | lesson | hidden-attr-vs-display | The HTML hidden attribute does not hide an element whose utility class sets display; hidden rows stayed visible and focusable. | evidence/review.txt | open
2026-11-03 | 3c9d1e7a | d5e09b13 | workflow | question-jargon | The agent asked the user to choose a fix in internal terms; the user answered "not following" and needed a plain re-ask. | "not following" | open
2026-11-03 | 3c9d1e7a | d5e09b13 | check | ui-js-untested | Server tests posted to a bare URL; the browser check found a form-post bug that no unit check covered. | taste.md | open
2026-11-03 | 3c9d1e7a | d5e09b13 | workflow | worker-stalled | A judge worker ended its turn without its done report after half its checks; the supervisor had to send a message to make it continue. | ledger.md | open
2026-11-04 | 3c9d1e7a | 6f7c2d90 | navigation | stale-agents-fact | The repo instructions named an old latest migration number; the agent found the real one only when generating a migration. | ledger.md | open
2026-11-04 | 3c9d1e7a | 6f7c2d90 | access | worker-permission-prompt | A worker stopped at a human permission prompt for a shell read; the coordinator could not answer it and the user had to act in the worker terminal. | ledger.md | open
R
cp "$ROOT/logs/review-log.md" "$W/log.before"
: > "$ROOT/logs/sizing-log.md"
