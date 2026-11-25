#!/usr/bin/env bash
# Tests skills/cooking/logs.sh on temporary repos: ids and the task map, the leak check, the push, two devices, and the project
# facts that it saves and prints, with a stub of `ai-memory`.
# Usage: tests/logs.sh
set -u

src="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
T="$(cd "$(mktemp -d)" && pwd -P)"; trap 'rm -rf "$T"' EXIT
export HOME="$T/userhome" GIT_CONFIG_GLOBAL="$T/gitconfig"
mkdir -p "$HOME"
git config --global user.name test; git config --global user.email test@example.invalid
git config --global commit.gpgsign false; git config --global init.defaultBranch main

fails=0
ok() { echo "ok   $1"; }
bad() { echo "FAIL $1"; fails=$((fails + 1)); }
check() { local name="$1"; shift; if "$@" >/dev/null 2>&1; then ok "$name"; else bad "$name"; fi; }
remote_has() { git -C "$T/logs.git" show main:review-log.md 2>/dev/null | grep -qF -- "$1"; }

# A device: a data folder, with logs/ as a clone of the shared remote. logs_sh <device> runs the script on that folder.
device() { mkdir -p "$1"; git clone -q "$T/logs.git" "$1/logs" 2>/dev/null; }
logs_sh() { local d="$1"; shift; JSTACK_DATA="$T/$d" "$src/skills/cooking/logs.sh" "$@"; }
git init -q --bare "$T/logs.git"
device "$T/a"; device "$T/b"
printf '*.md merge=union\n' > "$T/a/logs/.gitattributes"

# A task repo whose remote names an owner and a repo.
mkdir -p "$T/work"; git -C "$T/work" init -q; git -C "$T/work" remote add origin git@example.invalid:acme/shop-api.git
cd "$T/work"

out="$(logs_sh a ids add-export)"
check "ids prints two 8-character ids" grep -Eq '^repo=[0-9a-f]{8} task=[0-9a-f]{8}$' <<<"$out"
eval "$out"
check "the map resolves the ids" grep -qxF "$repo | $task | acme/shop-api | $T/work/.cookbook/dishes/add-export" "$T/a/overlays/tasks.txt"
logs_sh a ids add-export >/dev/null
check "a second call adds no map line" [ "$(wc -l < "$T/a/overlays/tasks.txt")" -eq 1 ]
mkdir -p .cookbook/meals/checkout/cart-totals
logs_sh a ids cart-totals >/dev/null
check "the map names the folder of a dish in a meal" grep -qF "| acme/shop-api | $T/work/.cookbook/meals/checkout/cart-totals" "$T/a/overlays/tasks.txt"
git -C "$T/work" commit -q --allow-empty -m init; git -C "$T/work" worktree add -q -b dish "$T/linked"
mkdir -p .cookbook/dishes/in-worktree
(cd "$T/linked" && logs_sh a ids in-worktree >/dev/null)
check "a linked worktree maps to the dish folder in the main checkout" grep -qF "| acme/shop-api | $T/work/.cookbook/dishes/in-worktree" "$T/a/overlays/tasks.txt"
git -C "$T/work" remote set-url origin https://example.invalid/acme/shop-api.git
check "the HTTPS remote gives the same ids" [ "$(logs_sh a ids add-export)" = "$out" ]
check "data prints the folder that JSTACK_DATA names" [ "$(logs_sh a data)" = "$T/a" ]
check "data prints the folder in the home directory when JSTACK_DATA is unset" [ "$(env -u JSTACK_DATA "$src/skills/cooking/logs.sh" data)" = "$HOME/.config/jstack" ]

log="$T/a/logs/review-log.md"
line() { echo "2026-10-02 | $repo | $task | workflow | $1 | $2 | ledger.md | open" >> "$log"; }
publish() { logs_sh "$1" publish >/dev/null 2>"$T/err"; echo $?; }

line brief-too-long 'the brief repeated the ask in three sections'
check "a generic line is pushed" [ "$(publish a)" = 0 ]
check "the remote holds it" remote_has brief-too-long

for leak in 'the Shop-API suite ran in full' 'a rule of acme was skipped' "the check lives in $HOME/work" 'read /Users/someone/notes first'; do
  cp "$log" "$T/keep"; line leak-tag "$leak"
  check "stops: $leak" [ "$(publish a)" = 1 ]
  check "prints the line: $leak" grep -qF -- "$leak" "$T/err"
  if remote_has leak-tag; then bad "the leak reached the remote: $leak"; else ok "nothing pushed: $leak"; fi
  cp "$T/keep" "$log"
done
check "the rewritten log is pushed again" [ "$(publish a)" = 0 ]

# Two devices append at the same time: the second push keeps both lines.
git -C "$T/b/logs" pull -q
echo "2026-10-03 | - | - | workflow | from-b | device b saw a wasted step | ledger.md | open" >> "$T/b/logs/review-log.md"
line from-a 'device a saw an unclear step'
check "device b pushes" [ "$(publish b)" = 0 ]
check "device a pushes after it" [ "$(publish a)" = 0 ]
check "the remote holds the line of b" remote_has from-b
check "the remote holds the line of a" remote_has from-a

# The tag index: one line for each tag, with the category and the event of the line that first used it.
line brief-too-long 'the brief repeated the ask in a fourth section'
idx="$(logs_sh a tags)"
check "tags prints a tag once, with its category, its count and its first event" grep -qxF 'brief-too-long | workflow | 2 | the brief repeated the ask in three sections' <<<"$idx"
check "tags prints one line for each tag" [ "$(grep -c . <<<"$idx")" -eq 3 ]

# A project fact: its page goes to ai-memory from the main checkout, and the script prints the last field of the fact's log line.
# The stub is first on PATH, and the server address is one that nothing answers: no call reaches the real memory.
mkdir -p "$T/bin"
cat > "$T/bin/ai-memory" <<'S'
#!/bin/sh
[ -z "${MEMORY_DOWN:-}" ] || { echo "could not reach the server" >&2; exit 1; }
if [ "$1" = read-page ]; then
  echo "cwd=$(pwd -P)" >> "$MEMORY_CALL.reads"
  [ -f "$MEMORY_STORE/$3" ] || { echo "Error: no such page" >&2; exit 1; }
  printf 'path: %s\n\n' "$3"; cat "$MEMORY_STORE/$3"; exit 0
fi
{ echo "cwd=$(pwd -P)"; echo "args=$*"; cat; } > "$MEMORY_CALL"
S
chmod +x "$T/bin/ai-memory"
export MEMORY_CALL="$T/memory-call" MEMORY_STORE="$T/memory-store" AI_MEMORY_SERVER_URL=http://127.0.0.1:9
fact() { (cd "$T/linked" && PATH="$T/bin:$PATH" logs_sh a fact "$@" 2>"$T/err"); }
printf '# Production shell\n\nRun `deployctl console`.\n' > "$T/fact.md"
check "fact prints applied with the page" [ "$(fact prod-shell "$T/fact.md")" = "applied $(date +%F) memory:facts/prod-shell.md" ]
check "fact saves the page from the main checkout, also when called in a linked worktree" grep -qxF "cwd=$T/work" "$T/memory-call"
check "fact names the page for the tag" grep -q -- '--path facts/prod-shell.md ' "$T/memory-call"
check "fact saves the file as the page" grep -qxF 'Run `deployctl console`.' "$T/memory-call"
rm -f "$T/memory-call"
echo "2026-10-04 | $repo | $task | navigation | canonical-domain | e | ledger.md | applied 2026-10-04 memory:facts/canonical-domain.md" >> "$log"
echo "2026-10-04 | 0a0a0a0a | 1b1b1b1b | navigation | seed-step | e | ledger.md | applied 2026-10-04 memory:facts/seed-step.md" >> "$log"
check "fact leaves a tag with an applied line of this repo open" [ "$(fact canonical-domain "$T/fact.md")" = open ]
check "fact saves no page for that tag" [ ! -e "$T/memory-call" ]
check "fact saves a tag whose applied line is of another repo" [ "$(fact seed-step "$T/fact.md")" = "applied $(date +%F) memory:facts/seed-step.md" ]
check "fact leaves the line open when memory is out of reach" [ "$(MEMORY_DOWN=1 fact scratch-db "$T/fact.md")" = open ]
check "fact says that the fact is not saved" grep -q 'not saved' "$T/err"
check "fact keeps the page of any tag inside facts/" [ "$(fact '../x y' "$T/fact.md")" = "applied $(date +%F) memory:facts/---x-y.md" ]
check "fact stops without a file" [ "$(fact prod-shell "$T/none.md"; echo $?)" = 64 ]

# The saved facts of a repo: each page that a line of the repo names, printed from the memory through the main checkout.
# The log of device a names canonical-domain for this repo and seed-step for another; the page of prod-shell is on another device.
echo "2026-10-05 | $repo | $task | navigation | prod-shell | e | ledger.md | applied 2026-10-05 memory:facts/prod-shell.md" >> "$log"
mkdir -p "$T/memory-store/facts"; echo 'The canonical domain is shop.example.com.' > "$T/memory-store/facts/canonical-domain.md"
echo 'Run the seed step.' > "$T/memory-store/facts/seed-step.md"
echo "2026-10-06 | - | - | workflow | from-b-late | device b saw a late step | ledger.md | open" >> "$T/b/logs/review-log.md"
check "device b pushes a later line" [ "$(publish b)" = 0 ]
saved="$(cd "$T/linked" && PATH="$T/bin:$PATH" logs_sh a facts 2>"$T/err")"
check "facts prints a page that a line of this repo names" grep -qxF 'The canonical domain is shop.example.com.' <<<"$saved"
check "facts names a page that this device cannot read" grep -qxF 'facts/prod-shell.md: this device cannot read the page' <<<"$saved"
if grep -q from-b-late "$log"; then bad "facts pulled the logs"; else ok "facts pulls no logs"; fi
if grep -q 'seed step' <<<"$saved"; then bad "facts prints the page of another repo"; else ok "facts leaves out the page of another repo"; fi
check "facts reads the memory from the main checkout" [ "$(sort -u "$T/memory-call.reads")" = "cwd=$T/work" ]
check "facts of a repo with no saved fact says so" [ "$(PATH="$T/bin:$PATH" logs_sh e facts)" = 'no project facts are saved for this repo' ]
check "facts creates no logs folder" [ ! -e "$T/e/logs" ]
check "facts creates no overlays folder" [ ! -e "$T/e/overlays" ]

# The closing line: a tag open in two dishes, a tag open again after an applied change, and a signal that two unspent lines missed.
# A tag is open again with a later date than its applied line, or below it on the same day; an open line above it on an earlier day is none.
mkdir -p "$T/d/logs"
check "summary of no logs counts nothing" [ "$(logs_sh d summary)" = '0 open observations' ]
cat > "$T/d/logs/review-log.md" <<'L'
2026-10-01 | r1 | d1 | workflow | gate-missed | e | ledger.md | open
2026-10-02 | r1 | d2 | workflow | gate-missed | e | ledger.md | open
2026-10-01 | r1 | d1 | check | slow-tests | e | ledger.md | applied 2026-10-02 skills/x.md
2026-10-03 | r1 | d2 | check | slow-tests | e | ledger.md | open
2026-10-03 | r1 | d2 | lesson | same-dish | e | ledger.md | open
2026-10-03 | r1 | d2 | lesson | same-dish | e | ledger.md | open
2026-10-03 | - | - | workflow | no-dish | e | "words" | open
2026-10-04 | - | - | workflow | no-dish | e | "words" | open
2026-10-05 | r1 | d1 | navigation | same-day | e | ledger.md | applied 2026-10-05 memory:facts/same-day.md
2026-10-05 | r1 | d3 | navigation | same-day | e | ledger.md | open
2026-10-05 | r1 | d4 | check | not-yet | e | ledger.md | open
2026-10-06 | r1 | d5 | check | not-yet | e | ledger.md | applied 2026-10-06 skills/x.md
2026-10-07 | r1 | d6 | check | later-above | e | ledger.md | open
2026-10-06 | r1 | d5 | check | later-above | e | ledger.md | applied 2026-10-06 skills/x.md
L
echo "2026-10-08 | $repo | $task | navigation | prod-shell | e | ledger.md | applied 2026-10-08 memory:facts/prod-shell.md" >> "$T/d/logs/review-log.md"
cat > "$T/d/logs/sizing-log.md" <<'L'
# Sizing log

2026-10-01 | r1 | d1 | predicted=standard | verdict=under | missed=reach
2026-10-02 | signal=reach | rejected
2026-10-02 | r1 | d2 | predicted=standard | verdict=under | missed=reach,risk
2026-10-03 | r1 | d3 | predicted=standard | verdict=under | missed=risk
L
check "summary names the tags and the signal that call for /improve" [ "$(logs_sh d summary)" = \
  '10 open observations; open in two dishes: gate-missed; open again after an applied change: slow-tests, same-day, later-above; missed in two unspent lines: risk; run /improve' ]
check "summary of a task names the memory pages of its lines" [ "$(logs_sh d summary add-export)" = \
  '10 open observations; saved to memory: facts/prod-shell.md; open in two dishes: gate-missed; open again after an applied change: slow-tests, same-day, later-above; missed in two unspent lines: risk; run /improve' ]

# A device without the clone writes locally and reports that nothing is pushed.
mkdir -p "$T/c/logs"
(cd "$T/c" && git init -q && printf '/logs/\n' > .gitignore)
check "no clone: publish exits 2" [ "$(publish c)" = 2 ]

[ "$fails" -eq 0 ] && echo "all passed" || echo "$fails failed"
[ "$fails" -eq 0 ]
