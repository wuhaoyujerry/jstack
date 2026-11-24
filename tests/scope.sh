#!/usr/bin/env bash
# Tests skills/cooking/scope.sh on a temporary repo: the count of added tests, new files, a rename, and the exit codes.
# Usage: tests/scope.sh
set -u

src="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
scope="$src/skills/cooking/scope.sh"
T="$(cd "$(mktemp -d)" && pwd -P)"; trap 'rm -rf "$T"' EXIT
export HOME="$T/userhome" GIT_CONFIG_GLOBAL="$T/gitconfig"
mkdir -p "$HOME" "$T/repo"
git config --global user.name test; git config --global user.email test@example.invalid
git config --global commit.gpgsign false; git config --global init.defaultBranch main

fails=0
ok() { echo "ok   $1"; }
bad() { echo "FAIL $1"; fails=$((fails + 1)); }
check() { local name="$1"; shift; if "$@" >/dev/null 2>&1; then ok "$name"; else bad "$name"; fi; }
# run <cases> [<base>]: sets $out and $code.
run() { out="$("$scope" "$@" 2>&1)"; code=$?; }

cd "$T/repo" && git init -q
printf 'def test_one():\n    assert True\n' > test_a.py
printf 'def add(a, b):\n    return a + b\n' > calc.py
git add -A && git commit -qm base

run 0
check "no change: exit 0 with a count of 0" [ "$code:$(tail -1 <<<"$out")" = "0:tests added: 0, listed: 0" ]

printf 'def add(a, b):\n    return b + a\n' > calc.py
printf '\ndef test_two():\n    assert True\n' >> test_a.py
run 1
check "one added test within one listed case: exit 0" [ "$code" = 0 ]
check "the changed files are listed" grep -Eq '^  M[[:space:]]+calc.py$' <<<"$out"

printf 'it("adds", () => {})\ntest.each([1])("n", () => {})\n' > calc.test.js
printf 'package calc\n\nfunc TestAdd(t *testing.T) {}\n' > calc_test.go
run 1
check "tests in new files count: exit 1" [ "$code" = 1 ]
check "four tests in three languages" grep -qx 'tests added: 4, listed: 1' <<<"$out"
check "a new file is listed" grep -Eq '^  A[[:space:]]+calc_test.go$' <<<"$out"

git add -A && git commit -qm unit
run 4 HEAD~1
check "a committed unit against its base: exit 0" [ "$code:$(tail -1 <<<"$out")" = "0:tests added: 4, listed: 4" ]

printf 'def test_first():\n    assert True\n\ndef test_two():\n    assert True\n' > test_a.py
run 0
check "a renamed test adds none" [ "$code:$(tail -1 <<<"$out")" = "0:tests added: 0, listed: 0" ]

run
check "no count: exit 2" [ "$code" = 2 ]
run 1 no-such-commit
check "an unknown base: exit 2" [ "$code" = 2 ]

[ "$fails" -eq 0 ] && echo "all passed" || echo "$fails failed"
[ "$fails" -eq 0 ]
