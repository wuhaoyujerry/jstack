#!/usr/bin/env bash
# The scope check of a saute unit: what the unit changed, and whether it adds more tests than its check lists.
# Usage: scope.sh <cases> [<base>]   in the unit's working tree, before its commit
#   <cases>  the number of test cases that the unit's check lists; 0 for a unit that reuses an existing test
#   <base>   the commit before the unit (default HEAD: the unit is not committed yet)
# Prints each file changed since <base>, new files too, then "tests added: <n>, listed: <cases>".
# A test is a line that declares one in Python, JavaScript or TypeScript, Go, Rust, Java or Kotlin, PHP, Ruby or Bats. A test that
# the unit removes or renames comes off the count. A test in another form counts 0: count those by hand.
# Exit: 1 the unit adds more tests than its check lists; 2 wrong usage.
set -euo pipefail

case "${1:-}" in '' | *[!0-9]*) echo "usage: scope.sh <cases> [<base>]" >&2; exit 2 ;; esac
cases="$1"; base="${2:-HEAD}"
git rev-parse -q --verify "$base^{commit}" >/dev/null || { echo "scope.sh: no commit $base" >&2; exit 2; }

decl='^[[:space:]]*((async[[:space:]]+)?def test_|func Test[A-Z_]|(it|test)(\.[A-Za-z]+)*[[:space:]]*[(`]|(it|test|specify)[[:space:]]+["'\'']|#\[([a-z_]+::)?test|@(Test|ParameterizedTest)([^A-Za-z]|$)|(public[[:space:]]+)?function test|@test[[:space:]])'

# The unit's diff with no context lines; a new file is all added lines.
unit_diff() {
  git diff --no-color -U0 "$base" --
  git ls-files --others --exclude-standard -z | while IFS= read -r -d '' f; do
    git diff --no-color -U0 --no-index -- /dev/null "$f" || true
  done
}
# The test declarations among the lines that open with <sign>, without the file header lines.
count() { unit_diff | grep -E "^[$1]" | grep -Ev '^(\+\+\+|---) ' | cut -c2- | grep -cE "$decl" || true; }

n=$(($(count +) - $(count -)))
echo "files changed since $base:"
{ git diff --name-status "$base" --; git ls-files --others --exclude-standard | sed 's/^/A	/'; } | sed 's/^/  /'
echo "tests added: $n, listed: $cases"
if [ "$n" -gt "$cases" ]; then
  echo "scope: $((n - cases)) more than the unit's check lists"
  exit 1
fi
