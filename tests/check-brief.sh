#!/usr/bin/env bash
# Tests skills/idea/check-brief.sh on briefs in a temporary directory: each limit, the words it does not count, and a missing file.
# Usage: tests/check-brief.sh
set -u

src="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
T="$(cd "$(mktemp -d)" && pwd -P)"; trap 'rm -rf "$T"' EXIT
script="$src/skills/idea/check-brief.sh"

fails=0
ok() { echo "ok   $1"; }
bad() { echo "FAIL $1"; fails=$((fails + 1)); }
check() { local name="$1"; shift; if "$@" >/dev/null 2>&1; then ok "$name"; else bad "$name"; fi; }

# brief <name> writes the brief from stdin; run <name> leaves the output in $out and the exit code in $code.
brief() { cat > "$T/$1.md"; }
run() { out="$("$script" "$T/$1.md" 2>&1)"; code=$?; }
w() { local i s=""; for i in $(seq "$1"); do s="$s word"; done; printf '%s' "${s# }"; }   # w <n>: a sentence of n words

# A brief that keeps every limit, with the forms an agent writes: bullets and numbers, labels, dates.
brief good <<B
# Brief: sample
## Goal

$(w 15)

## What it does
- $(w 15)
- one
- two
- three
- four
## How we check
1. $(w 15)
2. two
3. three
## Done-checks
- $(w 20)
1. $(w 20)
## Non-goals
$(w 40)
## Open facts
- \`code\` here, and $(w 40)
## Contested shape: no
## Decisions
- D1 Attempts. $(w 20) (2026-11-10)
- D2 (2026-11-10): $(w 20)
- D3 Wait (2026-11-10): $(w 20)
- D4. $(w 20).
- $(w 20)
B
run good
check "a brief within every limit prints nothing" [ -z "$out" ]
check "and exits 0" [ "$code" -eq 0 ]

# One fault each. The other sections stay valid, so the output names only that fault.
fault() { # <name> <section> <line>
  { printf '# Brief: sample\n## Goal\nA short goal.\n## What it does\n- One change.\n## How we check\n- One look.\n'
    printf '## Done-checks\n- One outcome.\n## Decisions\n- One choice.\n'; } > "$T/$1.md"
  awk -v h="## $2" -v add="$3" '{ print } $0 == h { print add }' "$T/$1.md" > "$T/$1.tmp" && mv "$T/$1.tmp" "$T/$1.md"
}

fault user16 "What it does" "- $(w 16)"; run user16
check "a user line of 16 words is printed" grep -q '^What it does: 16 words, limit 15: ' <<<"$out"
check "and the exit is 1" [ "$code" -eq 1 ]

fault goal16 "Goal" "$(w 16)"; run goal16
check "a goal of 16 words is printed" grep -q '^Goal: 16 words, limit 15: ' <<<"$out"
check "a second goal line is printed" grep -q '^Goal: 2 lines, limit 1$' <<<"$out"

fault code "How we check" "- Run \`pytest\` once."; run code
check "code in a user line is printed" grep -q '^How we check: code in a line for the user: ' <<<"$out"

fault check21 "Done-checks" "- $(w 21)"; run check21
check "a done-check of 21 words is printed" grep -q '^Done-checks: 21 words, limit 20: ' <<<"$out"

fault decision21 "Decisions" "- D7 Wait. $(w 21) (2026-11-10)"; run decision21
check "a decision of 21 words is printed, without its label and date" grep -q '^Decisions: 21 words, limit 20: word word' <<<"$out"

# A bracket that holds no date is part of the sentence.
fault bracket "Decisions" "- $(w 19) (two words)"; run bracket
check "a bracket without a date counts as words" grep -q '^Decisions: 21 words, limit 20: ' <<<"$out"

# The limit of lines: 6 changes, 4 looks.
{ printf '# Brief: sample\n## Goal\nA short goal.\n## What it does\n'; for i in 1 2 3 4 5 6; do echo "- Change $i."; done
  printf '## How we check\n'; for i in 1 2 3 4; do echo "- Look $i."; done; printf '## Decisions\n- One choice.\n'; } > "$T/lines.md"
run lines
check "a sixth change is printed" grep -q '^What it does: 6 lines, limit 5$' <<<"$out"
check "a fourth look is printed" grep -q '^How we check: 4 lines, limit 3$' <<<"$out"
printf '## How we check\n- a\n- b\n- c\n- d\n' > "$T/last.md"; run last
check "the last section of a file is checked too" [ "$out" = "How we check: 4 lines, limit 3" ]

run missing
check "a missing brief exits 2" [ "$code" -eq 2 ]
"$script" >/dev/null 2>&1; check "no argument exits 2" [ "$?" -eq 2 ]

[ "$fails" -eq 0 ] && echo "all passed" || echo "$fails failed"
[ "$fails" -eq 0 ]
