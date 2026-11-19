. "$(dirname "$0")/../../lib.sh"
agent_ended
log="$ROOT/overlays/review-log.md"
grep -q ' | open$' "$log" || fail "review wrote no observation"
# Every observation: a tag of one to three words, and a file given as an absolute path.
awk -F' [|] ' '/ [|] open$/ { n = split($5, w, /[-_ ]+/); if (n < 1 || n > 3) { print "tag has " n " words: " $5; bad = 1 }
  if ($7 !~ /^\//) { print "file is not absolute: " $7; bad = 1 } } END { exit bad }' "$log" > "$W/lines.bad" || fail "$(head -3 "$W/lines.bad")"
