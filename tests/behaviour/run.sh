#!/usr/bin/env bash
# Behavioural tests: run a headless Pi agent on a seeded fixture, then assert on the files it leaves.
# Usage: tests/behaviour/run.sh [case ...]
# Env: RUNS per case and model (default 3), MODELS (space-separated), MODEL_MAP (another model map), TIMEOUT (seconds per turn), KEEP=1 keeps passing run dirs,
# SRC tests the skills of another checkout (for example a worktree of an older commit).
# A case may add prompt2.txt, prompt3.txt ...: each continues the same session as the user's next message (reply in out2.txt ...).
# between.sh, if present, runs after turn 1 to save state for assert.sh.
# The agent starts in the fixture repo. A case whose prompt names the improve skill starts in the skills copy, the home of
# /improve; a `from-repo` file in such a case starts it in the fixture repo. A `cwd` file starts it in that path under the run dir.
# An `orca-worktrees` file makes the orca stub create each worktree that `worktree create` or `worker-start` names, under $W/wt,
# and print the reply of that call. An `orca-inbox` file makes the stub print that file at the first `orchestration check`, and
# accept `ask`, `reply` and `send`, which it only logs.
# An `ai-memory` stub keeps each page that `write-page` gets under $W/memory and prints it for `read-page`: no run reaches the real memory.
# A symbolic link to a case folder is an alias: the id of a second scenario that the case asserts too. It runs by name; a run of
# every case skips it.
set -u

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "${SRC:-$here/../..}" && pwd)"
RUNS="${RUNS:-3}"
# The main agent is one of these two, so every case runs on both. A machine with another provider name or another main-agent model
# maps it in overlays/model-map.txt, one "<provider or id> <replacement>" per line: `openai-codex openai` renames a provider, and
# `anthropic/claude-fable-5-2 anthropic/claude-opus-5-5` replaces a model. The map changes these defaults only, never a given MODELS.
if [ -z "${MODELS:-}" ]; then
  MODELS="openai-codex/gpt-6.2-sol:medium anthropic/claude-fable-5-2:medium"
  map="${MODEL_MAP:-$here/../../overlays/model-map.txt}"
  if [ -f "$map" ]; then
    while read -r from to; do
      [ -n "$to" ] || continue
      # A line with a slash names a whole id, which ends at the effort; any other line names a provider.
      case "$from" in */*) end=: ;; *) end=/ ;; esac
      MODELS="$(printf '%s\n' $MODELS | sed "s#^$from$end#$to$end#" | tr '\n' ' ')"
    done < "$map"
  fi
fi
TIMEOUT="${TIMEOUT:-900}"

# A model id that Pi lacks on this machine fails every run, with the cause only in pi.err: stop before any run.
for m in $MODELS; do
  id="${m%:*}"
  pi --list-models "$id" 2>/dev/null | awk -v p="${id%%/*}" -v n="${id#*/}" '$1 == p && $2 == n { f = 1 } END { exit !f }' && continue
  echo "run.sh: Pi lists no model $id on this machine. Map its provider or its id in overlays/model-map.txt, or set MODELS to ids that 'pi --list-models' prints." >&2
  exit 2
done

if [ "$#" -gt 0 ]; then cases=("$@"); else
  cases=(); for d in "$here"/cases/*/; do [ -L "${d%/}" ] || cases+=("$(basename "$d")"); done
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
  cat > "$W/bin/orca" <<S
#!/bin/sh
echo "\$*" >> "$ORCA_LOG"
call="\$1 \$2"
if [ -e "$case_dir/orca-worktrees" ] && { [ "\$call" = "worktree create" ] || [ "\$call" = "orchestration worker-start" ]; }; then
  name=; base=HEAD
  while [ \$# -gt 0 ]; do case "\$1" in --name) name="\$2";; --base-branch) base="\$2";; esac; shift; done
  # The agent or worker that the call names is never started: the log line is its only trace.
  if [ -n "\$name" ] && git worktree add -q -b "\$name" "$W/wt/\$name" "\$base" >/dev/null 2>&1; then
    if [ "\$call" = "worktree create" ]; then
      printf '{"ok":true,"result":{"worktree":{"path":"%s","branch":"refs/heads/%s"}}}\n' "$W/wt/\$name" "\$name"
    else
      printf '{"ok":true,"result":{"dispatchId":"ctx_%s","state":"ready","workspace":"repo::%s","keptOpen":true,"next":"Orca wakes you when workers report; end your turn when you are done."}}\n' "\$name" "$W/wt/\$name"
    fi
    exit 0
  fi
fi
# Mail between agents: the first check prints the inbox of the case. A message that the agent sends is only logged, with its body file.
if [ -e "$case_dir/orca-inbox" ]; then
  case "\$call" in
  "orchestration check")
    if [ -s "$case_dir/orca-inbox" ] && [ ! -e "$W/inbox-read" ]; then : > "$W/inbox-read"; cat "$case_dir/orca-inbox"; else echo "No unread messages."; fi
    exit 0 ;;
  "orchestration ask" | "orchestration reply" | "orchestration send")
    while [ \$# -gt 0 ]; do if [ "\$1" = --body-file ] && [ -f "\$2" ]; then cat "\$2" >> "$ORCA_LOG"; fi; shift; done
    echo "messageId=msg_test\$\$"
    exit 0 ;;
  esac
fi
echo "orca: unavailable in this test" >&2
exit 1
S
  # Memory: a page is a file under $W/memory, which a setup may seed. $W/memory.log holds each call with its directory.
  cat > "$W/bin/ai-memory" <<S
#!/bin/sh
echo "\$(pwd -P) | \$*" >> "$W/memory.log"
cmd="\${1:-}"; path=; body=
while [ \$# -gt 0 ]; do case "\$1" in --path) path="\${2:-}";; --body) body="\${2:-}";; esac; shift; done
case "\$cmd" in write-page|read-page) ;; *) echo "ai-memory: unavailable in this test" >&2; exit 1;; esac
case "\$path" in ""|/*|*..*) echo "ai-memory: --path must name a page" >&2; exit 2;; esac
if [ "\$cmd" = read-page ]; then
  [ -f "$W/memory/\$path" ] || { echo "Error: no page \$path" >&2; exit 1; }
  printf 'path: %s\n\n' "\$path"; cat "$W/memory/\$path"; exit 0
fi
mkdir -p "$W/memory/\$(dirname "\$path")"
if [ "\$body" = - ]; then cat > "$W/memory/\$path"; else printf '%s\n' "\$body" > "$W/memory/\$path"; fi
echo "wrote \$path under default/test"
S
  # A model query answers with a row, so the check of a model id before a worker start passes; it starts nothing and is not logged.
  printf 'pi() { if [ "$1" = --list-models ]; then echo "provider model"; echo "$2" | tr / " "; return 0; fi; echo "$*" >> "%s"; echo "pi: unavailable in this test" >&2; return 1; }\n' "$W/pi-nested.log" > "$W/bashenv"
  # The page tool of idea (skills/idea/gate-page.sh): a case has none, so its brief gate is the text form, unless its setup appends
  # another IDEA_PAGE_TOOL to this file. The tool keeps its state in its home, which stays in the run directory.
  printf 'export IDEA_PAGE_TOOL="%s" AM_HOME="%s"\n' "$W/no-page-tool/am.mjs" "$W/am-home" >> "$W/bashenv"
  chmod +x "$W/bin/orca" "$W/bin/ai-memory"; : > "$ORCA_LOG"

  (cd "$REPO" && bash "$case_dir/setup.sh") > "$W/setup.log" 2>&1 || { echo "FAIL $W (setup)"; return; }
  # The logs that setup wrote are the pushed state: the agent's lines are the only new ones.
  (cd "$ROOT/logs" && git add -A . && if ! git diff --cached --quiet; then git commit -qm fixture && git push -q -u origin HEAD; fi) >> "$W/setup.log" 2>&1

  local cwd="$REPO"
  if grep -q 'skills/improve/SKILL.md' "$case_dir/prompt.txt" && [ ! -e "$case_dir/from-repo" ]; then cwd="$ROOT"; fi
  if [ -f "$case_dir/cwd" ]; then cwd="$W/$(cat "$case_dir/cwd")"; fi

  local n=1 f="$case_dir/prompt.txt" out="$OUT" more=() prompt
  while [ -f "$f" ]; do
    prompt="$(sed "s|{{ROOT}}|$ROOT|g" "$f")"
    # The server address is one that nothing answers, for a call that reaches the real `ai-memory` past the stub.
    (cd "$cwd" && PATH="$W/bin:$PATH" BASH_ENV="$W/bashenv" AI_MEMORY_SERVER_URL=http://127.0.0.1:9 timeout "$TIMEOUT" pi -p --session-dir "$W/sessions" ${more[@]+"${more[@]}"} --no-extensions \
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
