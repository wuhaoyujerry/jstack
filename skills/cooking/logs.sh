#!/usr/bin/env bash
# The shared workflow logs: `logs/` in the data folder, a clone of a private Git repo that every device pushes to.
# The data folder holds this device's files, outside every skills checkout: $JSTACK_DATA, or ~/.config/jstack with none set.
# A log line names a repo and a task by id. The task map, overlays/tasks.txt there, resolves the ids on the device that ran the task.
# Usage: logs.sh data         prints the data folder
#        logs.sh ids <slug>   in the task's repo: pulls the logs, records the task in the map, prints "repo=<id> task=<id>"
#        logs.sh pull         pulls the logs
#        logs.sh tags         prints each tag of the review log once: "<tag> | <category> | <lines> | <first event>"
#        logs.sh fact <tag> <file>  in the task's repo: saves the file as a page of the project's memory in ai-memory, and prints
#                             the last field of the fact's log line: "applied <date> memory:<page>", or "open" with no page saved
#        logs.sh facts        in the task's repo: prints each page of the project's memory that a line of the repo names as saved
#        logs.sh summary [<slug>]  prints the closing line of review: the open observations, and what calls for /improve; with
#                             a slug, in the task's repo, also the memory pages that the lines of that task name
#        logs.sh publish      checks the unpushed lines for private names, then commits and pushes the logs
# Exit: 1 a line holds a private name (publish); 2 the logs are not pushed.
set -euo pipefail

data="${JSTACK_DATA:-$HOME/.config/jstack}"
logs="$data/logs"; map="$data/overlays/tasks.txt"

hash8() { printf %s "$1" | shasum -a 256 | cut -c1-8; }

# owner/repo from the origin URL, the same for its SSH and HTTPS forms; the folder name for a repo with no remote.
repo_key() {
  local url; url="$(git -C "$1" remote get-url origin 2>/dev/null || true)"
  if [ -n "$url" ]; then printf %s "$url" | sed -E 's#\.git$##; s#^.*[:/]([^/]+/[^/]+)$#\1#'; else basename "$1"; fi
}

# The main checkout of the task's repo, which Git lists first, also in a linked worktree; then the repo's key and its id.
repo_ids() {
  top="$(git worktree list --porcelain | sed -n '1s/^worktree //p')"
  key="$(repo_key "$top")"; repo="$(hash8 "$key")"
}

# Only its own .git makes logs/ the clone: a Git repo that holds the data folder does not.
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
data)
  echo "$data"
  ;;
ids)
  slug="${2:?usage: logs.sh ids <slug>}"
  # The cookbook is in the main checkout, also when the task ran in a linked worktree.
  repo_ids; task="$(hash8 "$key/$slug")"
  folder="$top/.cookbook/dishes/$slug"
  for d in "$top"/.cookbook/meals/*/"$slug"/; do [ -d "$d" ] && folder="${d%/}"; done
  pull || true
  mkdir -p "$logs" "$(dirname "$map")"; touch "$map"
  grep -qF "$repo | $task | " "$map" || printf '%s | %s | %s | %s\n' "$repo" "$task" "$key" "$folder" >> "$map"
  echo "repo=$repo task=$task"
  ;;
pull)
  pull || true
  ;;
tags)
  # The line that first used a tag gives its category and its event, cut so that the index stays one short read as the log grows.
  [ -f "$logs/review-log.md" ] || exit 0
  awk -F' [|] ' 'NF >= 8 { if (!($5 in n)) { order[++k] = $5; cat[$5] = $4; ev[$5] = substr($6, 1, 200) } n[$5]++ }
    END { for (i = 1; i <= k; i++) { t = order[i]; print t " | " cat[t] " | " n[t] " | " ev[t] } }' "$logs/review-log.md"
  ;;
summary)
  # One line. It names a tag that is open in two dishes or open again after an applied change, and a signal that two unspent
  # lines of the sizing log missed; a line above a signal's last marker is spent. A line without a dish counts for no dish.
  # A tag is open again when an open line of it has a later date than an applied one, or stands below one: the place of a line
  # holds on one day, where dates tie. A Git error costs only the pages, never the line.
  repo=; task=
  if [ -n "${2:-}" ]; then repo_ids 2>/dev/null || true; task="$(hash8 "${key:-}/$2")"; fi
  set --
  [ -f "$logs/review-log.md" ] && set -- "$@" kind=review "$logs/review-log.md"
  [ -f "$logs/sizing-log.md" ] && set -- "$@" kind=sizing "$logs/sizing-log.md"
  awk -F' [|] ' -v repo="$repo" -v task="$task" '
    function add(list, x) { return list (list ? ", " : "") x }
    kind == "review" && NF >= 8 {
      if (!($5 in seen)) { seen[$5] = 1; tag[++k] = $5 }
      if ($8 == "open") {
        n++; if ($2 " " $3 != "- -" && !in_dish[$5, $2, $3]++) dishes[$5]++
        if ($1 > last_open[$5]) last_open[$5] = $1
        if ($5 in first_applied) below[$5] = 1
      } else if ($8 ~ /^applied /) {
        if (!($5 in first_applied) || $1 < first_applied[$5]) first_applied[$5] = $1
        if (task != "" && $2 == repo && $3 == task && split($8, w, " ") == 3 && w[3] ~ /^memory:/ && !page[w[3]]++) saved = add(saved, substr(w[3], 8))
      }
    }
    kind == "sizing" && $2 ~ /^signal=/ { unspent[substr($2, 8)] = 0 }
    kind == "sizing" && $NF ~ /^missed=/ {
      m = split(substr($NF, 8), a, ",")
      for (i = 1; i <= m; i++) if (a[i] != "none") { if (!(a[i] in unspent)) signal[++j] = a[i]; unspent[a[i]]++ }
    }
    END {
      for (i = 1; i <= k; i++) {
        if (dishes[tag[i]] >= 2) two = add(two, tag[i])
        t = tag[i]; if ((t in first_applied) && ((t in below) || last_open[t] > first_applied[t])) again = add(again, t)
      }
      for (i = 1; i <= j; i++) if (unspent[signal[i]] >= 2) missed = add(missed, signal[i])
      line = (n + 0) " open observation" (n == 1 ? "" : "s")
      if (saved) line = line "; saved to memory: " saved
      if (two) line = line "; open in two dishes: " two
      if (again) line = line "; open again after an applied change: " again
      if (missed) line = line "; missed in two unspent lines: " missed
      print line ((two || again || missed) ? "; run /improve" : "")
    }' "$@" < /dev/null
  ;;
fact)
  # The page is named for the tag, so one cause keeps one page in a project. Any other character than a letter, a digit, `_` or
  # `-` becomes `-`, so every tag gives a page inside facts/.
  tag="${2:-}"; file="${3:-}"
  [ -n "$tag" ] && [ -s "$file" ] || { echo "usage: logs.sh fact <tag> <file>, with a file that holds the fact" >&2; exit 64; }
  page="facts/$(printf %s "$tag" | tr -c 'A-Za-z0-9_-' '-').md"
  repo_ids
  # An applied line of the tag in this repo means that an earlier change did not hold: the line stays open, and /improve decides.
  # The tag reaches awk through the environment, which keeps a backslash as it is.
  if [ -f "$logs/review-log.md" ] && TAG="$tag" awk -F' [|] ' -v r="$repo" '$2 == r && $5 == ENVIRON["TAG"] && $8 ~ /^applied / { f = 1 } END { exit !f }' "$logs/review-log.md"; then
    echo open; exit 0
  fi
  # ai-memory names the project from the directory of the call, and a linked worktree of a repo with no remote would get a
  # project of its own: call it in the main checkout.
  if out="$({ cd "$top" && ai-memory write-page --path "$page" --body - --kind fact; } < "$file" 2>&1)"; then
    echo "applied $(date +%F) memory:$page"
  else
    echo "logs: the fact is not saved, because ai-memory is out of reach: $out" >&2
    echo open
  fi
  ;;
facts)
  # The facts that earlier reviews saved about this project, for a session that starts a task. It reads only: it pulls no logs
  # and creates no folder, so a session can call it before it may change anything.
  repo_ids
  pages=""
  if [ -f "$logs/review-log.md" ]; then
    pages="$(awk -F' [|] ' -v r="$repo" '$2 == r && split($8, w, " ") == 3 && w[1] == "applied" && w[3] ~ /^memory:/ && !seen[w[3]]++ { print substr(w[3], 8) }' "$logs/review-log.md")"
  fi
  [ -n "$pages" ] || { echo "no project facts are saved for this repo"; exit 0; }
  # The memory is on one device: a page that this device cannot read is named, so that the session knows the fact exists.
  while IFS= read -r page; do
    (cd "$top" && ai-memory read-page --path "$page" 2>/dev/null) || echo "$page: this device cannot read the page"
    echo
  done <<< "$pages"
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
  sed -n '2,15p' "${BASH_SOURCE[0]}" >&2; exit 64
  ;;
esac
