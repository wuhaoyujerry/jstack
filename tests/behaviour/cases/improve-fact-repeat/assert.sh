. "$(dirname "$0")/../../lib.sh"
agent_ended
# The page that the applied entry names is read in the memory of the line's project: in its repo, or by its project name.
reads="$(grep -E '[|] read-page .*facts/canonical-domain' "$W/memory.log" 2>/dev/null)"
[ -n "$reads" ] || fail "the memory page was not read: $(cat "$W/memory.log" 2>/dev/null)"
printf '%s\n' "$reads" | grep -Eq '/shop-api[^|]* [|] |--project[ =][^ ]*shop-api' || fail "the page was read in another project: $reads"
# The repeat is a failed earlier fix, on the day of that fix too, and nothing is applied before the user approves.
grep -Eiq 'recurr|repeat|again|did not hold|didn.t hold|(fix|change|page|memory)[^.]{0,80}(fail|did not|didn.t|still)|(fail|earlier|previous|prior)[^.]{0,40}(fix|change)' "$OUT" ||
  fail "the reply does not mark a failed earlier fix: $(head -5 "$OUT")"
has "$JSTACK_DATA/logs/review-log.md" 'evidence/live-check\.txt [|] open$'
[ -z "$(git -C "$ROOT" status --porcelain -- skills)" ] || fail "a skill file changed: $(git -C "$ROOT" status --porcelain -- skills | head -3)"
[ -z "$(git -C "$W/shop-api" status --porcelain)" ] || fail "the repo changed: $(git -C "$W/shop-api" status --porcelain | head -3)"
