#!/usr/bin/env bash
# Tests which cases tests/behaviour/run.sh starts, on a copy of the runner with one case, one alias of it and a stub pi:
# a run of every case skips the alias, and the alias runs by name. Starts no agent.
# Usage: tests/run-alias.sh
set -u

src="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
T="$(cd "$(mktemp -d)" && pwd -P)"; trap 'rm -rf "$T"' EXIT
c="$T/tests/behaviour/cases"
mkdir -p "$c/one" "$T/skills" "$T/bin"; : > "$T/SCENARIOS.md"; : > "$T/SOURCES.md"
cp "$src/tests/behaviour/run.sh" "$T/tests/behaviour/"
echo : > "$c/one/setup.sh"; echo x > "$c/one/prompt.txt"; echo : > "$c/one/assert.sh"
ln -s one "$c/two"
# The stub lists every model of the provider `here` and fails as an agent, so a case ends at once with its assertion.
cat > "$T/bin/pi" <<'S'
#!/bin/sh
[ "$1" = --list-models ] || exit 1
printf 'provider  model\nhere      %s\n' "${2#here/}"
S
chmod +x "$T/bin/pi"

fails=0
run() { PATH="$T/bin:$PATH" RUNS=1 MODELS=here/gpt-x:medium "$T/tests/behaviour/run.sh" "$@" > "$T/out" 2>&1; }
check() { if eval "$2"; then echo "ok   $1"; else echo "FAIL $1"; fails=$((fails + 1)); fi; }

run
check "every case: runs the case" 'grep -q "^PASS one " "$T/out"'
check "every case: skips the alias" '! grep -q " two " "$T/out"'
run two
check "by name: runs the alias" 'grep -q "^PASS two " "$T/out"'

[ "$fails" -eq 0 ] && echo "all passed" || echo "$fails failed"
[ "$fails" -eq 0 ]
