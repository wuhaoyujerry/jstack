#!/usr/bin/env bash
# The shared workflow logs: `logs/` beside `skills/`, a clone of a private Git repo that every device pushes to.
# A log line names a repo and a task by id. The task map, overlays/tasks.txt, resolves the ids on the device that ran the task.
# Usage: logs.sh ids <slug>   in the task's repo: pulls the logs, records the task in the map, prints "repo=<id> task=<id>"
#        logs.sh pull         pulls the logs
#        logs.sh publish      checks the unpushed lines for private names, then commits and pushes the logs
# Exit: 1 a line holds a private name (publish); 2 the logs are not pushed.
set -euo pipefail

here="$(cd -P "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
home="$(cd "$here/../.." && pwd)"
logs="$home/logs"; map="$home/overlays/tasks.txt"

hash8() { printf %s "$1" | shasum -a 256 | cut -c1-8; }

# owner/repo from the origin URL, the same for its SSH and HTTPS forms; the folder name for a repo with no remote.
repo_key() {
  local url; url="$(git -C "$1" remote get-url origin 2>/dev/null || true)"
  if [ -n "$url" ]; then printf %s "$url" | sed -E 's#\.git$##; s#^.*[:/]([^/]+/[^/]+)$#\1#'; else basename "$1"; fi
}

# logs/ sits inside the skills checkout, which ignores it: only its own .git makes it the clone.
is_clone() { [ -e "$logs/.git" ]; }
has_upstream() { git -C "$logs" rev-parse -q --verify '@{u}' >/dev/null 2>&1; }

pull() {
  is_clone && has_upstream || return 0
  local out
  if ! out="$(git -C "$logs" pull -q --rebase --autostash 2>&1)"; then
    git -C "$logs" rebase --abort 2>/dev/null || true
    echo "logs: pull failed, so the logs may lack the lines of other devices: $out" >&2
    return 1
  fi
}

case "${1:-}" in
ids)
  slug="${2:?usage: logs.sh ids <slug>}"
  top="$(git rev-parse --show-toplevel)"
  key="$(repo_key "$top")"; repo="$(hash8 "$key")"; task="$(hash8 "$key/$slug")"
  pull || true
  mkdir -p "$logs" "$(dirname "$map")"; touch "$map"
  grep -qF "$repo | $task | " "$map" || printf '%s | %s | %s | %s\n' "$repo" "$task" "$key" "$top/.cookbook/$slug" >> "$map"
  echo "repo=$repo task=$task"
  ;;
pull)
  pull || true
  ;;
publish)
  is_clone || { echo "logs: $logs is not a clone of the logs repo; nothing is pushed" >&2; exit 2; }
  cd "$logs"
  git add -A .
  # Every line this device added or changed since the last push; with no push yet, every line.
  base="$(git rev-parse -q --verify '@{u}' 2>/dev/null || git hash-object -t tree /dev/null)"
  added="$(git diff --cached -U0 "$base" -- . | grep '^+[^+]' || true)"

  # Names from the task map: owner/repo, the owner, and a repo name that is more than one plain word.
  # A one-word name ("docs", "billing") identifies no repo and would stop every line that uses the word.
  names="$(mktemp)"; trap 'rm -f "$names"' EXIT
  if [ -f "$map" ]; then
    awk -F' [|] ' '{ n = split($3, p, "/"); if (n > 1) { print $3; print p[1] } if (p[n] ~ /[-_0-9]/) print p[n] }' "$map" | sort -u > "$names"
  fi
  leaks="$({ printf '%s\n' "$added" | grep -F -e /Users/ -e /home/ -e "$HOME" || true
    if [ -s "$names" ]; then printf '%s\n' "$added" | grep -iwF -f "$names" || true; fi; } | sort -u)"
  if [ -n "$leaks" ]; then
    echo "logs: these lines name a repo, its owner or a home path. Rewrite them, then publish again:" >&2
    printf '%s\n' "$leaks" | cut -c2- >&2
    exit 1
  fi

  git diff --cached --quiet || git commit -q -m "logs: update" || { echo "logs: commit failed; nothing is pushed" >&2; exit 2; }
  if has_upstream; then
    pull || exit 2
    git push -q || { echo "logs: push failed; the lines are committed in $logs" >&2; exit 2; }
  else
    git push -q -u origin HEAD || { echo "logs: push failed; the lines are committed in $logs" >&2; exit 2; }
  fi
  echo "logs: pushed"
  ;;
*)
  sed -n '2,7p' "${BASH_SOURCE[0]}" >&2; exit 64
  ;;
esac
