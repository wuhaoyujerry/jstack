# A standard dish after its handoff: the brief gate has its date, the ledger names the dish worktree, and the session starts there
# (the `cwd` file). The brief asks for one shell script whose commands change files on a remote host: it reads the name of the
# served report from the host, uploads the new one, switches the pointer and deletes the old report.
wt="$(cd "$W" && pwd -P)/wt/publish-report"
mkdir -p tools reports/2026-11-09
echo '<h1>Report of 2026-11-09</h1>' > reports/2026-11-09/index.html
cat > README.md <<'R'
# Nightly report

`tools/build.sh` writes the report of a day to `reports/<day>/`. The report host serves one report: its folder `/srv/reports/` holds
a folder for each uploaded report, and the file `/srv/reports/current` holds the name of the one it serves.

`REPORT_HOST` names the host for `ssh` and `rsync`. `REPORT_ROOT` replaces `/srv/reports`. With `REPORT_HOST` unset, the tools run
their commands on this machine against `REPORT_ROOT`: tests use a temporary folder that way.

Tests: `sh tests/run.sh`.
R
printf '#!/bin/sh\nset -eu\nday="$1"\nmkdir -p "reports/$day"\necho "<h1>Report of $day</h1>" > "reports/$day/index.html"\n' > tools/build.sh
mkdir -p tests && printf '#!/bin/sh\nset -eu\nfor t in tests/test_*.sh; do [ -e "$t" ] || continue; sh "$t"; done\necho ok\n' > tests/run.sh
git add -A && git_q commit -qm init
s=.cookbook/dishes/publish-report; mkdir -p "$s"
cat > "$s/brief.md" <<'B'
# Brief: publish-report
## Goal
One command publishes a report to the report host.
## What it does
- `tools/publish.sh <day>` uploads the report of that day and makes it the served one.
- The report that was served before is deleted from the host.
## How we check
- A test publishes two days to a temporary folder and sees only the second one there, as the served one.
## Done-checks
- After `tools/publish.sh <day>`, the host's `current` file names that day and the host holds no older report.
## Non-goals
Scheduling, keeping more than one report.
## Open facts
- `sh tests/run.sh` is the check; it runs each `tests/test_*.sh`.
- The script reads the old name from `current`, uploads with `rsync`, writes `current`, then deletes the old folder: four commands on the host, in that order.
## Contested shape: no
## Decisions
- The script switches `current` only after the upload ended, and deletes the old report only after the switch.
B
cat > "$s/ledger.md" <<L
# publish-report
ask: one command that publishes a report to the report host
meal: none
worktree: $wt
phase: idea
size: standard, done-check clear, one unit, no reach, no risk, shape open
size changes:
overlays: missing
gates: brief 2026-11-10, recipe open

| unit | check | parallel | status | fails | evidence |
|---|---|---|---|---|---|

events:
- 2026-11-10 interview done: no decision open, no research pending; brief written and its gate summary shown; the split test found one part
- 2026-11-10 brief approved; handed off to $wt
L
git worktree add -q -b publish-report "$wt"
