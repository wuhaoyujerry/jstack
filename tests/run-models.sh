#!/usr/bin/env bash
# Tests the model check of tests/behaviour/run.sh with a stub pi that lists one model. Starts no agent.
# Usage: tests/run-models.sh
set -u

src="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
T="$(cd "$(mktemp -d)" && pwd -P)"; trap 'rm -rf "$T"' EXIT
cat > "$T/pi" <<'S'
#!/bin/sh
[ "$1" = --list-models ] || { echo started >> "$(dirname "$0")/started"; exit 1; }
if [ "$2" = here/gpt-x ]; then printf 'provider  model  context\nhere      gpt-x  272K\n'; else echo "No models matching \"$2\""; fi
S
chmod +x "$T/pi"

fails=0
run() { PATH="$T:$PATH" MODELS="$1" "$src/tests/behaviour/run.sh" no-such-case > "$T/out" 2> "$T/err"; echo "$?" > "$T/exit"; }
check() { if eval "$2"; then echo "ok   $1"; else echo "FAIL $1"; fails=$((fails + 1)); fi; }

run "there/gpt-x:medium here/gpt-x:medium"
check "missing id: exits 2" '[ "$(cat "$T/exit")" = 2 ]'
check "missing id: names the id" 'grep -q "no model there/gpt-x " "$T/err"'
check "missing id: reaches no case" '[ ! -s "$T/out" ]'

run "here/gpt-x:medium"
check "listed id: reaches the cases" 'grep -q "no-such-case: no such case" "$T/out"'
check "starts no agent" '[ ! -e "$T/started" ]'

[ "$fails" -eq 0 ] && echo "all passed" || echo "$fails failed"
[ "$fails" -eq 0 ]
