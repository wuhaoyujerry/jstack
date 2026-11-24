#!/usr/bin/env bash
# Builds the gate page of a brief (SKILL.md, step 9): gate-page.html in the folder of the brief. The page holds the goal, the
# picture, and the lines of What it does, Non-goals (as "What stays the same") and How we check, each copied unchanged.
# answer-me-with-html renders it; the script opens no window.
# Usage: gate-page.sh <brief.md> <picture.md>
#        gate-page.sh --help    prints the two forms of a picture, with an example of each
# Env: IDEA_PAGE_TOOL, the path of am.mjs. When it is set, the script looks nowhere else.
# Output: "goal: <goal line>" and "page: file://<path>" (exit 0); "picture: <what is wrong>" (exit 1); "no page: <reason>" (exit 3).
# Exit: 0 the page is written; 1 the picture is rejected; 2 a wrong call; 3 the page cannot be built.
set -euo pipefail

# The tool: the override alone when it is set, else the two folders that the tool's own SKILL.md names.
find_tool() {
  local t
  if [ -n "${IDEA_PAGE_TOOL+set}" ]; then
    if [ -r "$IDEA_PAGE_TOOL" ]; then printf '%s\n' "$IDEA_PAGE_TOOL"; return 0; fi
    return 1
  fi
  for t in "$HOME/.agents/skills/answer-me-with-html/scripts/am.mjs" "$HOME/.claude/skills/answer-me-with-html/scripts/am.mjs"; do
    if [ -r "$t" ]; then printf '%s\n' "$t"; return 0; fi
  done
  return 1
}

usage() {
  cat <<'H'
Usage: gate-page.sh <brief.md> <picture.md>

Writes gate-page.html beside the brief and prints "goal: ..." and "page: file://...".
The picture file holds one picture and no other text, in one of two forms.

1. Parts connect: one fenced block of flow, state, tree, er or api. Start a line with
   "+ " for a part the dish adds, "- " for a part it removes and "~ " for a part it
   changes. Leave every other line bare.

   ```flow LR
   (Client) -> Picks a visit
   - Picks a visit -> Review page
   + Picks a visit -> {Skip allowed?}
   + {Skip allowed?} -> Review page: no
   + {Skip allowed?} -> [Review page, card on file]: yes
   Review page -> (Booking confirmed)
   ```

   In a flow, "A -> B: label" is a link. (A) is a start or an end, {A?} is a decision
   and [A, B] is a box whose text holds a comma. Name a node by its text alone. A
   marker starts the line and marks every link on it. "~ A" on a line without an
   arrow marks a changed node.

2. No parts connect: one table with this header.

   | Before | After |
   |---|---|
   | The button says Save | The button says Save draft |

Exit: 0 the page is written; 1 "picture: ..." names what the picture breaks;
3 "no page: ..." gives the reason that no page can be built; 2 a wrong call.
H
  local t
  if t="$(find_tool)"; then printf '\nThe syntax of another block type: node %s help <type>\n' "$t"; fi
}

if [ "${1:-}" = "--help" ] || [ "${1:-}" = "-h" ]; then usage; exit 0; fi
if [ "$#" -ne 2 ]; then echo "Usage: gate-page.sh <brief.md> <picture.md>" >&2; exit 2; fi
brief="$1"; picture="$2"
[ -f "$brief" ] || { echo "gate-page.sh: no brief at '$brief'" >&2; exit 2; }
[ -f "$picture" ] || { echo "gate-page.sh: no picture at '$picture'" >&2; exit 2; }

# section <heading>: the lines of that section of the brief, without blank lines and without a list marker.
section() {
  awk -v h="$1" '
    /^## / { s = substr($0, 4); sub(/[ \t]+$/, "", s); on = (s == h); next }
    on && /[^ \t]/ { sub(/^[ \t]*([-*]|[0-9]+[.)])[ \t]+/, ""); sub(/^[ \t]+/, ""); print }
  ' "$brief"
}

goal="$(section Goal | head -n 1)"
[ -n "$goal" ] || { echo "gate-page.sh: the brief at '$brief' has no goal line" >&2; exit 2; }
dir="$(cd "$(dirname "$brief")" && pwd -P)"
slug="$(sed -n 's/^# Brief:[[:space:]]*//p' "$brief" | head -n 1 | sed 's/[[:space:]]*$//')"
[ -n "$slug" ] || slug="$(basename "$dir")"
page="$dir/gate-page.html"

# A page of an earlier gate must not outlive a failure of this one.
rm -f -- "$page"

no_page() { echo "no page: $1"; exit 3; }
node_major="$(node -p 'process.versions.node.split(".")[0]' 2>/dev/null || true)"
case "$node_major" in ''|*[!0-9]*) node_major=0 ;; esac
[ "$node_major" -ge 20 ] || no_page "Node.js 20 or later is not on PATH"
tool="$(find_tool)" || no_page "answer-me-with-html is not installed"

# The form of the picture. A block is rendered by the tool, which checks its syntax; the script checks only that it is one block
# with a marker, or one Before and After table.
bad_picture() { echo "picture: $1"; exit 1; }
form="$(awk '
  /[^ \t]/ { n++; line[n] = $0 }
  END {
    if (n == 0) { print "the picture file is empty"; exit }
    if (line[1] ~ /^```/) {
      type = line[1]; sub(/^```/, "", type); sub(/[ \t].*$/, "", type)
      if (type !~ /^(flow|state|tree|er|api)$/) { print "the block type \"" type "\" is not flow, state, tree, er or api"; exit }
      fences = 0; markers = 0
      for (i = 1; i <= n; i++) { if (line[i] ~ /^```/) fences++; else if (line[i] ~ /^[ \t]*[-+~] /) markers++ }
      if (fences > 2) { print "the file holds more than one block; write one picture"; exit }
      if (fences < 2 || line[n] !~ /^```[ \t]*$/) { print "text stands beside the block; the file holds one picture and no other text"; exit }
      if (markers == 0) { print "no line of the block starts with \"+ \", \"- \" or \"~ \"; mark what the dish adds, removes or changes"; exit }
      print "ok"; exit
    }
    if (line[1] ~ /^[ \t]*\|/) {
      if (line[1] !~ /^[ \t]*\|[ \t]*Before[ \t]*\|[ \t]*After[ \t]*\|[ \t]*$/) { print "the header of the table is not \"| Before | After |\""; exit }
      if (n < 3 || line[2] !~ /^[ \t]*\|[ \t]*:?-+:?[ \t]*\|[ \t]*:?-+:?[ \t]*\|[ \t]*$/) { print "the table needs the line \"|---|---|\" and one row at least"; exit }
      for (i = 3; i <= n; i++) {
        if (line[i] !~ /^[ \t]*\|/) { print "text stands beside the table; the file holds one picture and no other text"; exit }
        row = line[i]; gsub(/\\\|/, "", row); cells = gsub(/\|/, "|", row) - 1
        if (cells != 2) { print "a row of the table has " cells " columns, want 2: " line[i]; exit }
      }
      print "ok"; exit
    }
    print "the file starts with text; it holds one fenced block or one Before and After table, and no other text"
  }
' "$picture")"
[ "$form" = "ok" ] || bad_picture "$form"

draft="$(mktemp "${TMPDIR:-/tmp}/gate-page.XXXXXX")"
trap 'rm -f -- "$draft"' EXIT
panel() { # <title> <heading of the brief>: a panel of unordered items, or nothing when the brief has no line there
  local lines; lines="$(section "$2" | sed 's/^/- /')"
  [ -z "$lines" ] || printf '\n## %s\n%s\n' "$1" "$lines"
}
{
  printf -- '---\ntitle: "Brief: %s"\nsubtitle: %s\nfile: brief-%s\ncols: 2\nstyle: off\n---\n' "$slug" "$goal" "$slug"
  printf '\n## What changes {span=2}\n'
  cat "$picture"
  panel "What it does" "What it does"
  panel "What stays the same" "Non-goals"
  panel "How we check {span=2}" "How we check"
} > "$draft"
# The draft line where the picture starts, to turn a line number of the tool into a line of the picture.
start="$(awk '/^## What changes/ { print NR + 1; exit }' "$draft")"

code=0
out="$(node "$tool" render "$draft" -o "$page" --no-open 2>&1)" || code=$?
if [ "$code" -eq 0 ] && [ -s "$page" ] && printf '%s\n' "$out" | grep -q '^✓'; then
  echo "goal: $goal"
  echo "page: file://$page"
  exit 0
fi
rm -f -- "$page"
if printf '%s\n' "$out" | grep -q '^✗'; then
  # The tool rejected the draft. Its other parts are copied lines, so the fault is in the picture.
  printf '%s\n' "$out" | awk -v start="$start" '
    /^✗/ { seen = 1; sub(/^✗[ \t]*/, "")
           if (match($0, /^L[0-9]+/)) { n = substr($0, 2, RLENGTH - 1) - start + 1; $0 = "line " n " of the picture" substr($0, RLENGTH + 1) }
           print "picture: " $0; next }
    seen && !/^[ \t]*draft:/ { print }
  '
  exit 1
fi
no_page "answer-me-with-html failed"
