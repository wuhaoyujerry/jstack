# A trivial dish stopped in taste: its one unit is `pass` but has no evidence file, so the session runs the unit's check again.
# The check needs the host of the live site. The README gives the default host of the hosting platform, where sign-in fails.
# The case's name gives no hint of memory, since an agent sees it in the path of the run folder.
# A fact that an earlier review saved in the project's memory names the host that works, and the log holds its line.
# The check records each host it runs on in one file of the run folder, also when it runs in a fresh checkout. It knows the host
# that works only as a digest, so its text gives no answer.
printf 'def signin_label(): return "Sign in"\n' > page.py
cat > live-check.sh <<'S'
# Usage: sh live-check.sh <host>. Signs in on the live site. The sign-in provider accepts one redirect host, kept here as a digest.
h="${1#*://}"; h="${h%%/*}"
echo "${h:-none}" >> "CALLS"
if [ "$(printf %s "$h" | shasum -a 256 | cut -c1-16)" = 951623a26f8b3388 ]; then echo "GET https://$h/login : 200, sign-in passes"; exit 0; fi
echo "GET https://${h:-none}/login : the sign-in provider rejects the redirect URI"; exit 1
S
printf '# Shop\n\nLive site: https://shop-web.hostplatform.example\n\nRun the live check with `sh live-check.sh <host>`.\n' > README.md
sed -i.bak "s#\"CALLS\"#\"$(cd "$W" && pwd -P)/live-calls\"#" live-check.sh && rm live-check.sh.bak
git add -A && git_q commit -qm 'rename the label of the sign-in button'
s=.cookbook/dishes/signin-label; mkdir -p "$s" "$ROOT/logs" "$W/memory/facts"
cat > "$s/ledger.md" <<'L'
# signin-label
ask: rename the label of the sign-in button
phase: taste
size: trivial, done-check clear, one unit, no reach, no risk, shape clear
size changes:
gates: brief open, recipe open

| unit | check | parallel | status | fails | evidence |
|---|---|---|---|---|---|
| label | sh live-check.sh <host of the live site> | no | pass | 0 | evidence/label-saute.txt |

events:
L
eval "$("$ROOT/skills/cooking/logs.sh" ids signin-label)"
cat > "$ROOT/logs/review-log.md" <<R
2026-11-04 | 3c9d1e7a | 6f7c2d90 | access | worker-permission-prompt | A worker stopped at a human permission prompt for a shell read; the coordinator could not answer it and the user had to act in the worker terminal. | ledger.md | open
2026-11-20 | $repo | 7a1c33e0 | navigation | canonical-domain | The live check first used the hosting platform's default host, which the sign-in provider rejects; the canonical domain was recorded only in the ledger of a sibling dish. | ledger.md | applied 2026-11-20 memory:facts/canonical-domain.md
R
: > "$ROOT/logs/sizing-log.md"
printf '# Canonical domain\n\nThe sign-in provider accepts only the canonical domain, shop.example.com. The default host of the hosting platform fails sign-in. Run a live check on shop.example.com.\n' > "$W/memory/facts/canonical-domain.md"
