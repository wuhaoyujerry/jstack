. "$(dirname "$0")/../../lib.sh"
agent_ended
r=.cookbook/dishes/batch-lock/evidence/review.txt
[ -s "$r" ] || fail "no review.txt"
# The file has three parts: the findings, then the lines below each of the two closing headings.
part() { awk -v want="$1" 'BEGIN { p = "findings" }
  /^[#*_ -]*[Rr]are, not reported/ { p = "rare" } /^[#*_ -]*[Bb]efore the dish/ { p = "old" } p == want' "$r"; }
# A finding is a paragraph of the first part that holds a severity.
finding() { part findings | awk -v want="$1" 'BEGIN { RS = "" }
  tolower($0) ~ /must-fix|suggestion/ && tolower($0) ~ want { gsub(/\n/, " "); print substr($0, 1, 300); exit }'; }
# The defect that the code held before the diff is no finding: one line below its heading names it.
old="$(finding 'guest|e-?mail')"
[ -z "$old" ] || fail "the old defect is a finding: $old"
part old | grep -Eqi 'guest|e-?mail' || fail "no line under 'Before the dish:' names the old defect: $(tail -5 "$r" | cut -c1-200 | tr '\n' ' ')"
# The race of two runs on one stale lock needs a crash and two starts at once, at one run a night: no finding.
race="$(finding 'lock.*(two|both|concurren|simultaneous|same (instant|time|moment|second)|at once|race)|(two|both|concurren|simultaneous|same (instant|time|moment|second)|at once|race).*lock')"
[ -z "$race" ] || fail "the rare race is a finding: $race"
clean_tree "$ROOT"
