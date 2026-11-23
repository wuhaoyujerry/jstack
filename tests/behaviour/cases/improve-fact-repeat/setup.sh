# One fact was slow to find twice on one day in one repo. The first line reads `applied`, with its page in the project's memory;
# the second is `open` below it. The task map has both dishes, and the evidence file of the second is in reach.
r="$W/shop-api"; d="$r/.cookbook/dishes"
mkdir -p "$ROOT/overlays" "$ROOT/logs" "$W/memory/facts" "$d/checkout-email" "$d/order-email/evidence"
(cd "$r" && git init -q && git remote add origin git@example.invalid:acme/shop-api.git && printf '.cookbook/\n' > .git/info/exclude &&
  printf '# Shop API\n\nThe hosting platform deploys the default branch.\n' > AGENTS.md && git add -A && git_q commit -qm init)
cat > "$d/order-email/evidence/live-check.txt" <<'E'
GET https://shop-web.hostplatform.example/login : the sign-in provider rejects the redirect URI
grep -rn domain AGENTS.md README.md docs/ : no match
ledgers of two earlier dishes: no line on the domain
ledger of the dish checkout-email: the canonical domain is shop.example.com
GET https://shop.example.com/login : 200, sign-in passes
E
today="$(date +%F)"
cat > "$ROOT/logs/review-log.md" <<L
$today | 5c1e0a77 | 91f3b2d4 | navigation | canonical-domain | The live check first used the hosting platform's default host, which the sign-in provider rejects; the canonical domain was recorded only in the ledger of a sibling dish. | ledger.md | applied $today memory:facts/canonical-domain.md
$today | 5c1e0a77 | c07d6e18 | navigation | canonical-domain | The live check again used the hosting platform's default host and failed sign-in; the agent found the canonical domain only after three probes of the ledgers of earlier dishes. | evidence/live-check.txt | open
L
cat > "$ROOT/overlays/tasks.txt" <<L
5c1e0a77 | 91f3b2d4 | acme/shop-api | $d/checkout-email
5c1e0a77 | c07d6e18 | acme/shop-api | $d/order-email
L
: > "$ROOT/logs/sizing-log.md"
printf '# Canonical domain\n\nThe sign-in provider accepts only the canonical domain, shop.example.com. The default host of the hosting platform fails sign-in.\n' > "$W/memory/facts/canonical-domain.md"
