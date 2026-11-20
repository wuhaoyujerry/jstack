#!/usr/bin/env bash
# Behavioural tests: run a headless Pi agent on a seeded fixture, then assert on the files it leaves.
# Usage: tests/behaviour/run.sh [case ...]
# Env: RUNS per case and model (default 3), MODELS (space-separated), TIMEOUT (seconds per turn), KEEP=1 keeps passing run dirs,
# SRC tests the skills of another checkout (for example a worktree of an older commit).
# A case may add prompt2.txt, prompt3.txt ...: each continues the same session as the user's next message (reply in out2.txt ...).
# between.sh, if present, runs after turn 1 to save state for assert.sh.
# The agent starts in the fixture repo. A case whose prompt names the improve skill starts in the skills copy, the home of
# /improve; a `from-repo` file in such a case starts it in the fixture repo.
set -u

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "${SRC:-$here/../..}" && pwd)"
RUNS="${RUNS:-3}"
# The main agent is one of these two, so every case runs on both.
MODELS="${MODELS:-openai-codex/gpt-6.2-sol:medium anthropic/claude-fable-5-2:medium}"
TIMEOUT="${TIMEOUT:-900}"

if [ "$#" -gt 0 ]; then cases=("$@"); else
  cases=(); for d in "$here"/cases/*/; do cases+=("$(basename "$d")"); done
fi

git_q() { git -c user.name=test -c user.email=test@example.invalid -c commit.gpgsign=false "$@" >/dev/null; }
export -f git_q

run_one() { # <case> <model>; prints "pass" or "FAIL <workdir>"
  local MODEL="$2"
  local case_dir="$here/cases/$1" W
  W="$(mktemp -d "${TMPDIR:-/tmp}/jstack-bt-$1-XXXXXX")"
  export MODEL W ROOT="$W/jstack" REPO="$W/repo" OUT="$W/out.txt" ORCA_LOG="$W/orca.log"

  # A copy of the skills: the agent's logs and edits land here, never in the real checkout, overlays or logs.
  # Its logs/ is a clone of an empty remote in the run dir, so a push of the logs stays there.
  mkdir -p "$ROOT" "$REPO" "$W/bin"
  cp -R "$repo_root/skills" "$repo_root/SCENARIOS.md" "$repo_root/SOURCES.md" "$ROOT/"
  (cd "$ROOT" && git init -q && printf '/overlays/\n/logs/\n' > .gitignore && printf '.cookbook/\n' > .git/info/exclude && git add -A && git_q commit -qm base)
  git init -q --bare "$W/logs.git" && git clone -q "$W/logs.git" "$ROOT/logs" 2>/dev/null
  (cd "$ROOT/logs" && git config user.name test && git config user.email test@example.invalid && git config commit.gpgsign false)
  (cd "$REPO" && git init -q && printf '.cookbook/\n' > .git/info/exclude)

  # Workers and other sessions are out of scope: a stub records each attempt to start one, through orca or pi.
  # Pi puts its own bin directory first on PATH, so the pi stub is a function that the agent's bash loads from BASH_ENV.
  printf '#!/bin/sh\necho "$*" >> "%s"\necho "orca: unavailable in this test" >&2\nexit 1\n' "$ORCA_LOG" > "$W/bin/orca"
  # A model query answers with a row, so the check of a model id before a worker start passes; it starts nothing and is not logged.
  printf 'pi() { if [ "$1" = --list-models ]; then echo "provider model"; echo "$2" | tr / " "; return 0; fi; echo "$*" >> "%s"; echo "pi: unavailable in this test" >&2; return 1; }\n' "$W/pi-nested.log" > "$W/bashenv"
  chmod +x "$W/bin/orca"; : > "$ORCA_LOG"

  (cd "$REPO" && bash "$case_dir/setup.sh") > "$W/setup.log" 2>&1 || { echo "FAIL $W (setup)"; return; }
  # The logs that setup wrote are the pushed state: the agent's lines are the only new ones.
  (cd "$ROOT/logs" && git add -A . && if ! git diff --cached --quiet; then git commit -qm fixture && git push -q -u origin HEAD; fi) >> "$W/setup.log" 2>&1

  local cwd="$REPO"
  if grep -q 'skills/improve/SKILL.md' "$case_dir/prompt.txt" && [ ! -e "$case_dir/from-repo" ]; then cwd="$ROOT"; fi

  local n=1 f="$case_dir/prompt.txt" out="$OUT" more=() prompt
  while [ -f "$f" ]; do
    prompt="$(sed "s|{{ROOT}}|$ROOT|g" "$f")"
    (cd "$cwd" && PATH="$W/bin:$PATH" BASH_ENV="$W/bashenv" timeout "$TIMEOUT" pi -p --session-dir "$W/sessions" ${more[@]+"${more[@]}"} --no-extensions \
      --no-skills --no-context-files --no-mcp --no-prompt-templates --model "$MODEL" "$prompt") > "$out" 2>> "$W/pi.err"
    echo "$?" > "$W/pi.exit"; [ "$(cat "$W/pi.exit")" = 0 ] || break
    if [ "$n" -eq 1 ] && [ -f "$case_dir/between.sh" ]; then (cd "$REPO" && bash "$case_dir/between.sh") > "$W/between.log" 2>&1; fi
    n=$((n + 1)); f="$case_dir/prompt$n.txt"; out="$W/out$n.txt"; more=(--continue)
  done

  if (cd "$REPO" && bash "$case_dir/assert.sh") > "$W/assert.log" 2>&1; then
    [ -n "${KEEP:-}" ] || rm -rf "$W"; echo pass
  else
    echo "FAIL $W"
  fi
}

status=0
for c in "${cases[@]}"; do
  [ -d "$here/cases/$c" ] || { echo "$c: no such case"; status=2; continue; }
  pids=(); outs=()
  for m in $MODELS; do
    for _ in $(seq "$RUNS"); do
      o="$(mktemp)"; outs+=("$m $o"); run_one "$c" "$m" > "$o" & pids+=("$!")
    done
  done
  wait "${pids[@]}"
  for m in $MODELS; do
    passed=0; fails=""
    for mo in "${outs[@]}"; do
      [ "${mo% *}" = "$m" ] || continue; o="${mo#* }"
      if [ "$(cat "$o")" = pass ]; then passed=$((passed + 1)); else fails="$fails $(cut -d' ' -f2- "$o")"; fi
      rm -f "$o"
    done
    if [ "$passed" -eq "$RUNS" ]; then echo "PASS $c $m $passed/$RUNS"; else echo "FAIL $c $m $passed/$RUNS:$fails"; status=1; fi
  done
done
exit "$status"
