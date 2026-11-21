#!/usr/bin/env bash
# Tests skills/cooking/logs.sh on temporary repos: ids and the task map, the leak check, the push, and two devices.
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

# A device: a skills checkout with the script, and logs/ as a clone of the shared remote.
device() {
  mkdir -p "$1/skills/cooking"; cp "$src/skills/cooking/logs.sh" "$1/skills/cooking/"
  git clone -q "$T/logs.git" "$1/logs" 2>/dev/null
}
git init -q --bare "$T/logs.git"
device "$T/a"; device "$T/b"
printf '*.md merge=union\n' > "$T/a/logs/.gitattributes"

# A task repo whose remote names an owner and a repo.
mkdir -p "$T/work"; git -C "$T/work" init -q; git -C "$T/work" remote add origin git@example.invalid:acme/shop-api.git
cd "$T/work"

out="$("$T/a/skills/cooking/logs.sh" ids add-export)"
check "ids prints two 8-character ids" grep -Eq '^repo=[0-9a-f]{8} task=[0-9a-f]{8}$' <<<"$out"
eval "$out"
check "the map resolves the ids" grep -qxF "$repo | $task | acme/shop-api | $T/work/.cookbook/dishes/add-export" "$T/a/overlays/tasks.txt"
"$T/a/skills/cooking/logs.sh" ids add-export >/dev/null
check "a second call adds no map line" [ "$(wc -l < "$T/a/overlays/tasks.txt")" -eq 1 ]
mkdir -p .cookbook/meals/checkout/cart-totals
"$T/a/skills/cooking/logs.sh" ids cart-totals >/dev/null
check "the map names the folder of a dish in a meal" grep -qF "| acme/shop-api | $T/work/.cookbook/meals/checkout/cart-totals" "$T/a/overlays/tasks.txt"
git -C "$T/work" remote set-url origin https://example.invalid/acme/shop-api.git
check "the HTTPS remote gives the same ids" [ "$("$T/a/skills/cooking/logs.sh" ids add-export)" = "$out" ]

log="$T/a/logs/review-log.md"
line() { echo "2026-10-02 | $repo | $task | workflow | $1 | $2 | ledger.md | open" >> "$log"; }
publish() { "$T/$1/skills/cooking/logs.sh" publish >/dev/null 2>"$T/err"; echo $?; }

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

# A device without the clone writes locally and reports that nothing is pushed.
mkdir -p "$T/c/skills/cooking" "$T/c/logs"; cp "$src/skills/cooking/logs.sh" "$T/c/skills/cooking/"
(cd "$T/c" && git init -q && printf '/logs/\n' > .gitignore)
check "no clone: publish exits 2" [ "$(publish c)" = 2 ]

[ "$fails" -eq 0 ] && echo "all passed" || echo "$fails failed"
[ "$fails" -eq 0 ]
