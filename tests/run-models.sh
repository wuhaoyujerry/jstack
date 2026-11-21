#!/usr/bin/env bash
# Tests the model check of tests/behaviour/run.sh with a stub pi that lists only the models of the provider `here`. Starts no agent.
# Usage: tests/run-models.sh
set -u

src="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
T="$(cd "$(mktemp -d)" && pwd -P)"; trap 'rm -rf "$T"' EXIT
cat > "$T/pi" <<'S'
#!/bin/sh
[ "$1" = --list-models ] || { echo started >> "$(dirname "$0")/started"; exit 1; }
case "$2" in here/*) printf 'provider  model  context\nhere      %s  272K\n' "${2#here/}" ;; *) echo "No models matching \"$2\"" ;; esac
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

# With no MODELS, the default ids take their providers from the map; without a map line they stay as written.
printf 'openai-codex here\nanthropic here\n' > "$T/map"
MODEL_MAP="$T/map" run ""
check "mapped defaults: reaches the cases" 'grep -q "no-such-case: no such case" "$T/out"'
MODEL_MAP="$T/no-map" run ""
check "no map: stops on the default id" '[ "$(cat "$T/exit")" = 2 ] && grep -q "no model openai-codex/" "$T/err"'
check "starts no agent" '[ ! -e "$T/started" ]'

[ "$fails" -eq 0 ] && echo "all passed" || echo "$fails failed"
[ "$fails" -eq 0 ]
