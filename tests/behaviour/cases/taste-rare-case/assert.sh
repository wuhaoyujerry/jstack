. "$(dirname "$0")/../../lib.sh"
agent_ended
r=.cookbook/dishes/receipt/evidence/review.txt
[ -s "$r" ] || fail "no review.txt"
# The common defect is a finding.
has "$r" '[Cc]oupon'
# The rare defect is no finding: the file names it only below the heading for rare cases. A finding is a paragraph, above that
# heading, that holds a severity.
finding="$(sed '/[Rr]are, not reported/,$d' "$r" | awk 'BEGIN { RS = ""; IGNORECASE = 1 }
  tolower($0) ~ /must-fix|suggestion/ && tolower($0) ~ /currenc|keyerror|symbols/ { gsub(/\n/, " "); print substr($0, 1, 300); exit }')"
[ -z "$finding" ] || fail "the rare case is a finding: $finding"
clean_tree "$ROOT"
