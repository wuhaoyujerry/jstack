# Two open ledgers match the ask "add retry to the fetch client".
echo 'def fetch(url): return url' > client.py
git add -A && git_q commit -qm init
for slug in fetch-retry retry-fetch-client; do
  mkdir -p ".cookbook/dishes/$slug"
  cat > ".cookbook/dishes/$slug/ledger.md" <<L
# $slug
ask: add retry to the fetch client
phase: idea
size: standard, done-check open, one unit, no reach, no risk, shape open
size changes:
gates: brief open, recipe open

| unit | check | parallel | status | fails | evidence |
|---|---|---|---|---|---|

events:
L
done
cp -R .cookbook "$W/cookbook-before"
