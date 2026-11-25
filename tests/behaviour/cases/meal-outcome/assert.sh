. "$(dirname "$0")/../../lib.sh"
agent_ended
# The merge of the done dish conflicts: the meal agent aborts it, and the meal branch stays where it was.
if git -C "$W/wt/checkout" rev-parse -q --verify MERGE_HEAD > /dev/null 2>&1; then fail "the merge was not aborted"; fi
[ "$(git -C "$W/wt/checkout" rev-parse HEAD)" = "$(cat "$W/meal-head")" ] || fail "the meal branch moved"
# It records the conflict itself, as an outcome of that dish: an observation under the dish's ids whose file is the session's own file.
ids="$(awk -F' [|] ' '$4 ~ /\/cart-export$/ { print $1 " | " $2 }' "$JSTACK_DATA/overlays/tasks.txt" 2>/dev/null)"
[ -n "$ids" ] || fail "the task map lacks cart-export"
line="$(grep -F " | $ids | " "$JSTACK_DATA/logs/review-log.md" | head -1)"
[ -n "$line" ] || fail "no observation for cart-export: $(cat "$JSTACK_DATA/logs/review-log.md")"
f="$(printf '%s\n' "$line" | awk -F' [|] ' '{ print $7 }')"
case "$f" in *.jsonl) [ -f "$W/sessions/$f" ] || fail "no session file has the name: $f" ;; *) fail "file is not the name of the session's file: $line" ;; esac
pushed review-log.md " [|] $ids [|] "
no_workers
