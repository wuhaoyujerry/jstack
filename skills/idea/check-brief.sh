#!/usr/bin/env bash
# Checks a brief against the limits of the idea skill (SKILL.md, step 8) and prints each line that breaks one.
# Usage: check-brief.sh <brief.md>
# Not counted as words: a list marker; in a decision, a label at its start such as "D3 Errors." or "D3 (2026-11-10):", and a
# date in brackets at its end.
# Exit: 0 the brief keeps every limit; 1 a line breaks one; 2 no brief at that path.
set -euo pipefail

[ -f "${1:-}" ] || { echo "check-brief.sh: no brief at '${1:-}'" >&2; exit 2; }

awk '
function words(s,   a) { return split(s, a, " ") }
# The sections for the user have a limit of lines; it is checked when the section ends.
function close_section() {
  if ((sec in max_lines) && lines > max_lines[sec]) { printf "%s: %d lines, limit %d\n", sec, lines, max_lines[sec]; bad = 1 }
  lines = 0
}
BEGIN { max_lines["Goal"] = 1; max_lines["What it does"] = 5; max_lines["How we check"] = 3 }
/^## / { close_section(); sec = substr($0, 4); sub(/[ \t]+$/, "", sec); next }
!/[^ \t]/ { next }
{
  item = ($0 ~ /^[ \t]*([-*]|[0-9]+[.)])[ \t]/)
  l = $0; sub(/^[ \t]*([-*]|[0-9]+[.)])[ \t]+/, "", l)
  if (sec in max_lines) {
    lines++
    if (l ~ /`/) { printf "%s: code in a line for the user: %s\n", sec, l; bad = 1 }
    if (words(l) > 15) { printf "%s: %d words, limit 15: %s\n", sec, words(l), l; bad = 1 }
  } else if ((sec == "Done-checks" || sec == "Decisions") && item) {
    sub(/^D[0-9]+[^.:]*[.:][ \t]+/, "", l)
    sub(/[ \t]*\([0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]\)\.?[ \t]*$/, "", l)
    if (words(l) > 20) { printf "%s: %d words, limit 20: %s\n", sec, words(l), l; bad = 1 }
  }
}
END { close_section(); exit bad }
' "$1"
