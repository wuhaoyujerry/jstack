. "$(dirname "$0")/../../lib.sh"
agent_ended
log="$ROOT/logs/review-log.md"
# An observation is open, or a project fact that review saved: its line then reads applied with the memory page.
obs=' [|] (open|applied [0-9-]+ memory:[^ ]+)$'
grep -Eq "$obs" "$log" || fail "review wrote no observation"
# Every observation: a tag of one to three words, an id for the repo and for the task, and a file given by its path in the task folder.
awk -F' [|] ' '$8 == "open" || $8 ~ /^applied / { n = split($5, w, /[-_ ]+/); if (n < 1 || n > 3) { print "tag has " n " words: " $5; bad = 1 }
  if (length($2 $3) != 16 || $2 $3 !~ /^[0-9a-f]+$/) { print "repo or task is not an id: " $2 " | " $3; bad = 1 }
  if ($7 ~ /^\// || $7 ~ /\.cookbook/) { print "file is not a path in the task folder: " $7; bad = 1 } } END { exit bad }' "$log" > "$W/lines.bad" || fail "$(head -3 "$W/lines.bad")"
# The task map resolves the ids on this machine, and the logs are pushed.
has "$ROOT/overlays/tasks.txt" '\.cookbook/dishes/rename-parse$'
pushed review-log.md "$obs"
