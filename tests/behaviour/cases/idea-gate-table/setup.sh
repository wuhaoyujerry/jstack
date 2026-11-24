# Idea runs alone, without cooking: no ledger. The user settled every decision, answered the closing question and asked for
# the brief. The change is one of wording: one message gets a new text, and no part connects to another.
# The page tool is the real answer-me-with-html: this case needs it installed.
tool=""
for t in "$HOME/.agents/skills/answer-me-with-html/scripts/am.mjs" "$HOME/.claude/skills/answer-me-with-html/scripts/am.mjs"; do
  if [ -z "$tool" ] && [ -r "$t" ]; then tool="$t"; fi
done
[ -n "$tool" ] || { echo "setup: answer-me-with-html is not installed; this case needs the real tool"; exit 1; }
printf 'export IDEA_PAGE_TOOL="%s"\n' "$tool" >> "$W/bashenv"
printf 'import urllib.request\n\ndef fetch(url):\n    try:\n        return urllib.request.urlopen(url).read()\n    except OSError:\n        raise RuntimeError("fetch failed")\n' > client.py
git add -A && git_q commit -qm init
mkdir -p .cookbook/dishes/error-wording
cat > .cookbook/dishes/error-wording/brief.md <<'B'
# Brief: error-wording
## Decisions
- D1 Text. A failed download reports "Could not reach the server. Try again in a minute." (2026-11-10)
- D2 Scope. Only the text of the message changes; the kind of error stays. (2026-11-10)
- Closing question. Nothing is missing. (2026-11-10)
B
