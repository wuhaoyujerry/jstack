#!/usr/bin/env bash
# Tests skills/idea/gate-page.sh in a temporary directory: the page it builds, each picture it rejects, each reason for no page.
# A stub of the tool shows the call and the draft. The cases that need the real answer-me-with-html print "skip" without it.
# Usage: tests/gate-page.sh
set -u

src="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
T="$(cd "$(mktemp -d)" && pwd -P)"; trap 'rm -rf "$T"' EXIT
script="$src/skills/idea/gate-page.sh"
# The tool keeps its state in its home: keep that, and the draft of the script, inside the temporary directory.
export AM_HOME="$T/am-home" TMPDIR="$T/tmp"; mkdir -p "$TMPDIR"
unset IDEA_PAGE_TOOL

fails=0
ok() { echo "ok   $1"; }
bad() { echo "FAIL $1"; fails=$((fails + 1)); }
skip() { echo "skip $1"; }
check() { local name="$1"; shift; if "$@" >/dev/null 2>&1; then ok "$name"; else bad "$name"; fi; }
holds() { grep -Fq -- "$2" "$1"; }                # holds <file> <text>
lacks() { ! grep -Eq -- "$2" "$1"; }              # lacks <file> <regex>

real=""
for t in "$HOME/.agents/skills/answer-me-with-html/scripts/am.mjs" "$HOME/.claude/skills/answer-me-with-html/scripts/am.mjs"; do
  if [ -z "$real" ] && [ -r "$t" ]; then real="$t"; fi
done

# The stub logs its arguments to $STUB_LOG and the draft to $STUB_LOG.draft. STUB_MODE: ok writes a page that holds the draft,
# reject answers as the tool does to a bad block, on the line after the fence, and fail exits 1 with no such line.
mkdir -p "$T/stub"; stub="$T/stub/am.mjs"; export STUB_LOG="$T/stub/log"
cat > "$stub" <<'S'
import { readFileSync, writeFileSync, appendFileSync } from "node:fs";
const a = process.argv.slice(2);
appendFileSync(process.env.STUB_LOG, a.join(" ") + "\n");
const draft = readFileSync(a[1], "utf8");
writeFileSync(process.env.STUB_LOG + ".draft", draft);
const mode = process.env.STUB_MODE || "ok";
if (mode === "fail") { console.log("boom"); process.exit(1); }
if (mode === "reject") {
  const n = draft.split("\n").findIndex((l) => l.startsWith("```flow")) + 2;
  console.log(`✗ L${n} [flow] bad link`); console.log("  Correct example:"); console.log("  draft: /somewhere/else.md"); process.exit(1);
}
const out = a[a.indexOf("-o") + 1];
writeFileSync(out, `<textarea id="am-source">${draft}</textarea>`);
console.log(`✓ ${out}`);
S

# dish <name> writes the brief from stdin to $T/<name>/brief.md; pic <name> writes the picture from stdin.
dish() { mkdir -p "$T/$1"; cat > "$T/$1/brief.md"; }
pic() { mkdir -p "$T/$1"; cat > "$T/$1/gate-picture.md"; }
# run <name> [VAR=value ...]: leaves the output in $out and the exit code in $code.
run() { local d="$T/$1"; shift; out="$(env "$@" "$script" "$d/brief.md" "$d/gate-picture.md" 2>&1)"; code=$?; }
full_brief() {
  cat <<'B'
# Brief: sample

## Goal

Signed-in clients book without the card check.

## What it does

- A client with a saved card confirms with no card page.
* Everyone else keeps the card check.

## How we check

1. Sign in and book again.
2) Sign out and book.

## Done-checks

- DONECHECK one outcome.

## Non-goals

- No change to fees.
A plain line of non-goals.

## Open facts

- OPENFACT one note.

## Terms

- TERMWORD: one sentence.

## Contested shape: no

## Decisions

- D1 Scope. DECISION one choice. (2026-11-10)
B
}
flow_picture() { printf '```flow LR\n(Client) -> Picks a visit\n- Picks a visit -> Review page\n+ Picks a visit -> {Skip allowed?}\n+ {Skip allowed?} -> Review page: no\nReview page -> (Booking confirmed)\n```\n'; }
table_picture() { printf '| Before | After |\n|---|---|\n| The button says Save | The button says Save draft |\n'; }

# (i) The call and the draft, with the stub.
full_brief | dish call; flow_picture | pic call; : > "$STUB_LOG"
run call IDEA_PAGE_TOOL="$stub"
check "a brief and a block with markers exit 0" [ "$code" -eq 0 ]
check "the output holds the goal line" grep -qx 'goal: Signed-in clients book without the card check\.' <<<"$out"
check "the output holds the page as a file link" grep -qx "page: file://$T/call/gate-page.html" <<<"$out"
check "the output holds nothing else" [ "$(printf '%s\n' "$out" | wc -l)" -eq 2 ]
check "the page is written beside the brief" [ -s "$T/call/gate-page.html" ]
check "the tool gets render, the page as -o and --no-open" grep -Eq "^render [^ ]+ -o $T/call/gate-page\.html --no-open\$" "$STUB_LOG"
d="$STUB_LOG.draft"
check "the draft names the brief, the goal and two columns, with the style check off" \
  [ "$(sed -n 1,7p "$d" | tr '\n' '|')" = '---|title: "Brief: sample"|subtitle: Signed-in clients book without the card check.|file: brief-sample|cols: 2|style: off|---|' ]
check "the panels come in the order of the example" \
  [ "$(grep '^## ' "$d" | tr '\n' '|')" = '## What changes {span=2}|## What it does|## What stays the same|## How we check {span=2}|' ]
check "the picture stands in the first panel, unchanged" [ "$(sed -n '/^## What changes/,/^## What it does/p' "$d" | sed '1d;$d' | sed '/^$/d')" = "$(flow_picture)" ]
check "each line of What it does is an unordered item, unchanged" \
  [ "$(sed -n '/^## What it does/,/^## What stays/p' "$d" | grep '^- ' | tr '\n' '|')" = '- A client with a saved card confirms with no card page.|- Everyone else keeps the card check.|' ]
check "Non-goals are the lines of What stays the same" \
  [ "$(sed -n '/^## What stays/,/^## How we check/p' "$d" | grep '^- ' | tr '\n' '|')" = '- No change to fees.|- A plain line of non-goals.|' ]
check "a numbered line of How we check loses its number" \
  [ "$(sed -n '/^## How we check/,$p' "$d" | grep '^- ' | tr '\n' '|')" = '- Sign in and book again.|- Sign out and book.|' ]
check "the draft holds no line of the recipe sections" lacks "$d" 'DONECHECK|OPENFACT|TERMWORD|DECISION|Done-checks|Open facts|Decisions|Contested'
check "the script leaves no draft behind" [ -z "$(ls -A "$TMPDIR")" ]

# (j) A second gate overwrites the page.
table_picture | pic call; run call IDEA_PAGE_TOOL="$stub"
check "a Before and After table exits 0" [ "$code" -eq 0 ]
check "the second run replaces the page" holds "$T/call/gate-page.html" 'Save draft'
check "and the picture of the first run is gone" lacks "$T/call/gate-page.html" 'Picks a visit'

# (h) A brief with no non-goals gets no such panel.
full_brief | sed '/^## Non-goals/,/^## Open facts/{/^## Open facts/!d;}' | dish nogoals; table_picture | pic nogoals
run nogoals IDEA_PAGE_TOOL="$stub"
check "a brief without non-goals exits 0" [ "$code" -eq 0 ]
check "and its draft has no panel What stays the same" lacks "$STUB_LOG.draft" 'What stays the same'

# (c) Each picture that the script rejects: exit 1, one line that starts "picture:", no page.
reject() { # <name> <text the line must hold>; the picture comes from stdin
  full_brief | dish "$1"; pic "$1"; : > "$T/$1/gate-page.html"
  run "$1" IDEA_PAGE_TOOL="$stub"
  check "$1: exit 1" [ "$code" -eq 1 ]
  check "$1: the line says what is wrong" grep -q "^picture: .*$2" <<<"$out"
  check "$1: no page stays" [ ! -e "$T/$1/gate-page.html" ]
}
printf '```flow\nA -> B\nB -> C\n```\n' | reject no-marker 'starts with'
printf '| Before | After | Why |\n|---|---|---|\n| a | b | c |\n' | reject three-columns 'Before | After'
printf '| Before | After |\n|---|---|\n| a | b | c |\n' | reject wide-row '3 columns'
{ flow_picture; flow_picture; } | reject two-blocks 'more than one block'
{ echo 'The change in one picture:'; flow_picture; } | reject text-before 'starts with text'
{ flow_picture; echo 'A note after the picture.'; } | reject text-after 'no other text'
printf '```mermaid\n+ A --> B\n```\n' | reject other-type 'mermaid'
: | reject empty 'empty'

# A block that the tool rejects: the line of the tool becomes a line of the picture.
full_brief | dish tool-reject; flow_picture | pic tool-reject
run tool-reject IDEA_PAGE_TOOL="$stub" STUB_MODE=reject
check "a block that the tool rejects exits 1" [ "$code" -eq 1 ]
check "its line number counts from the picture" grep -qx 'picture: line 2 of the picture \[flow\] bad link' <<<"$out"
check "the help of the tool follows, without the path of its draft copy" [ "$(printf '%s\n' "$out" | sed -n 2,9p)" = "  Correct example:" ]
check "and no page stays" [ ! -e "$T/tool-reject/gate-page.html" ]

# (d) (f) (e) No page: exit 3 and one line with a fixed reason.
full_brief | dish nopage; flow_picture | pic nopage; echo old > "$T/nopage/gate-page.html"
run nopage IDEA_PAGE_TOOL="$T/no-such-tool/am.mjs"
check "a tool that is missing exits 3" [ "$code" -eq 3 ]
check "with the reason on one line" [ "$out" = "no page: answer-me-with-html is not installed" ]
check "and the page of an earlier gate is gone" [ ! -e "$T/nopage/gate-page.html" ]
printf '```flow\nA -> B\n```\n' | pic nopage
run nopage IDEA_PAGE_TOOL="$T/no-such-tool/am.mjs"
check "without the tool, a bad picture also exits 3" [ "$code" -eq 3 ]
flow_picture | pic nopage; run nopage IDEA_PAGE_TOOL="$stub" STUB_MODE=fail
check "a tool that fails exits 3" [ "$code" -eq 3 ]
check "with its own reason" [ "$out" = "no page: answer-me-with-html failed" ]
check "and leaves no page" [ ! -e "$T/nopage/gate-page.html" ]
if PATH=/usr/bin:/bin command -v node >/dev/null 2>&1; then skip "a PATH without node: /usr/bin or /bin holds node"; else
  run nopage PATH=/usr/bin:/bin IDEA_PAGE_TOOL="$stub"
  check "a PATH without node exits 3" [ "$code" -eq 3 ]
  check "with the Node reason" [ "$out" = "no page: Node.js 20 or later is not on PATH" ]
fi

# (g) A wrong call exits 2.
"$script" "$T/none/brief.md" "$T/call/gate-picture.md" >/dev/null 2>&1; check "no brief exits 2" [ "$?" -eq 2 ]
"$script" "$T/call/brief.md" "$T/none/gate-picture.md" >/dev/null 2>&1; check "no picture file exits 2" [ "$?" -eq 2 ]
"$script" "$T/call/brief.md" >/dev/null 2>&1; check "one argument exits 2" [ "$?" -eq 2 ]
printf '# Brief: sample\n## Goal\n\n## Decisions\n- One choice.\n' | dish nogoal; table_picture | pic nogoal
run nogoal IDEA_PAGE_TOOL="$stub"; check "a brief without a goal line exits 2" [ "$code" -eq 2 ]
check "--help shows both forms" [ "$("$script" --help | grep -Ec '^   ```flow|^   \| Before \| After \|')" -eq 2 ]

# (a) (b) The real tool.
if [ -z "$real" ]; then skip "the real tool: answer-me-with-html is not installed"; else
  full_brief | dish real; flow_picture | pic real; run real
  check "real tool: a block with markers exits 0" [ "$code" -eq 0 ]
  check "real tool: the output names the page" grep -qx "page: file://$T/real/gate-page.html" <<<"$out"
  p="$T/real/gate-page.html"
  check "real tool: the page holds its draft" holds "$p" '<textarea id="am-source"'
  for text in 'Signed-in clients book without the card check.' 'What changes' 'What it does' 'What stays the same' 'How we check' \
    'A client with a saved card confirms with no card page.' 'Everyone else keeps the card check.' 'No change to fees.' 'Sign out and book.'; do
    check "real tool: the page holds: $text" holds "$p" "$text"
  done
  check "real tool: the page holds no line of the recipe sections" lacks "$p" 'DONECHECK|OPENFACT|TERMWORD|DECISION'
  table_picture | pic real; run real
  check "real tool: a Before and After table exits 0" [ "$code" -eq 0 ]
  check "real tool: the page holds the table" holds "$T/real/gate-page.html" 'The button says Save draft'
  printf '```flow\n+ A -> B\nB -> + C\n```\n' | pic real; run real
  check "real tool: a block with a bad link exits 1" [ "$code" -eq 1 ]
  check "real tool: the line counts from the picture" grep -q '^picture: line 3 of the picture' <<<"$out"
  check "real tool: no page stays" [ ! -e "$T/real/gate-page.html" ]
  check "real tool: its state stays in the temporary directory" [ -e "$AM_HOME/state.json" ]
fi

[ "$fails" -eq 0 ] && echo "all passed" || echo "$fails failed"
[ "$fails" -eq 0 ]
