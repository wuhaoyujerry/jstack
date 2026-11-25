# A dish stopped in review. Its ledger records four events, each with its evidence file:
# - a shell command of the project that took long to find: a project fact;
# - a stalled worker: a gap in the workflow, with no project fact;
# - a size that the user corrected because no file states the launch state: a project fact, and a gap in the size step;
# - a slow lookup of the canonical domain: a project fact whose tag reads `applied` in the log since an earlier dish of the day,
#   with its page in the project's memory.
printf 'def export_csv(orders):\n    return "\\n".join(",".join(map(str, o)) for o in orders)\n' > orders.py
printf 'grep -q "def export_csv" orders.py\n' > check.sh
git add -A && git_q commit -qm 'add the orders export'
s=.cookbook/dishes/orders-export; mkdir -p "$s/evidence" "$JSTACK_DATA/logs" "$W/memory/facts"
echo 'sh check.sh: exit 0' > "$s/evidence/export-saute.txt"
cat > "$s/evidence/prod-shell.txt" <<'E'
grep -rn shell AGENTS.md README.md docs/ : no match
search of an earlier session file for the shell command: three probes
found: deployctl console --app shop-web --process worker
deployctl console --app shop-web --process worker : connected
E
cat > "$s/evidence/verifier-stall.txt" <<'E'
verifier worker: turn ended after 4 of 8 checks, no done report
coordinator: sent "continue with the remaining checks"
verifier worker: done report, 8 of 8 checks pass
E
cat > "$s/evidence/size-change.txt" <<'E'
size: large. Risk: the export goes to production and mails real customers.
AGENTS.md, README.md: no line on whether production has users
user: "the app is still in development, it has no active users yet, so this is not that risky"
size: large -> standard
E
cat > "$s/evidence/live-check.txt" <<'E'
GET https://shop-web.hostplatform.example/login : the sign-in provider rejects the redirect URI
grep -rn domain AGENTS.md README.md docs/ : no match
ledger of the dish checkout-email: the canonical domain is shop.example.com
GET https://shop.example.com/login : 200, sign-in passes
E
cat > "$s/taste.md" <<'T'
| check | state | evidence | reason |
|---|---|---|---|
| sh check.sh | pass | evidence/export-saute.txt | the builder ran it |
| sign-in on the live site | pass | evidence/live-check.txt | the verifier ran it on the canonical domain |
T
cat > "$s/ledger.md" <<'L'
# orders-export
ask: add a CSV export of orders
phase: review
size: standard, done-check clear, one unit, no reach, no risk, shape clear
size changes: large -> standard, the user said that the app has no active users yet
gates: brief 2026-11-20, recipe 2026-11-20

| unit | check | parallel | status | fails | evidence |
|---|---|---|---|---|---|
| export | sh check.sh | no | pass | 0 | evidence/export-saute.txt |

events:
- size: set to large on the Risk signal without a check of whether production has users; the instructions did not say, and the user lowered it: the app is in development with no active users (evidence/size-change.txt)
- saute: the command for a production app shell was found only in an earlier session file, after three probes; the instructions describe the deploy service but not its shell command (evidence/prod-shell.txt)
- taste: the verifier worker ended its turn without its done report after half its checks; the coordinator sent a message to make it continue (evidence/verifier-stall.txt)
- taste: the live check first used the hosting platform's default host, which the sign-in provider rejects; the canonical domain was found only in the ledger of a sibling dish (evidence/live-check.txt)
L
eval "$("$ROOT/skills/cooking/logs.sh" ids orders-export)"
today="$(date +%F)"
cat > "$JSTACK_DATA/logs/review-log.md" <<R
2026-11-03 | 3c9d1e7a | d5e09b13 | workflow | question-jargon | The agent asked the user to choose a fix in internal terms; the user answered "not following" and needed a plain re-ask. | "not following" | open
2026-11-04 | 3c9d1e7a | 6f7c2d90 | access | worker-permission-prompt | A worker stopped at a human permission prompt for a shell read; the coordinator could not answer it and the user had to act in the worker terminal. | ledger.md | open
$today | $repo | 7a1c33e0 | navigation | canonical-domain | The live check first used the hosting platform's default host, which the sign-in provider rejects; the canonical domain was recorded only in the ledger of a sibling dish. | ledger.md | applied $today memory:facts/canonical-domain.md
R
cp "$JSTACK_DATA/logs/review-log.md" "$W/log.before"
: > "$JSTACK_DATA/logs/sizing-log.md"
printf '# Canonical domain\n\nThe sign-in provider accepts only the canonical domain, shop.example.com. The default host of the hosting platform fails sign-in.\n' > "$W/memory/facts/canonical-domain.md"
cp "$W/memory/facts/canonical-domain.md" "$W/domain-page.before"
