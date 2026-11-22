# A local upstream whose writing-for-agents skill gained one line after the recorded commit.
up="$W/upstream"; mkdir -p "$up/skills"
cp -R "$ROOT/skills/writing-for-agents" "$up/skills/"
(cd "$up" && git init -q && git add -A && git_q commit -qm base)
base="$(git -C "$up" rev-parse HEAD)"
echo '- Prefer a table to a list when every item has the same fields.' >> "$up/skills/writing-for-agents/SKILL.md"
(cd "$up" && git add -A && git_q commit -qm 'add table rule')
cat > "$ROOT/SOURCES.md" <<S
# Sources

| Collection | Upstream | Commit read |
|---|---|---|
| Matt Pocock skills | $up | \`$base\` |

| cooking file (relative to \`skills/cooking/\`) | Source skill | Kept | Dropped |
|---|---|---|---|
| \`../writing-for-agents/\` | \`writing-for-agents\` (Matt Pocock) | \`SKILL.md\` and \`SKILL-MECHANICS.md\`, verbatim, with the MIT license | \`agents/openai.yaml\` (Codex UI metadata) |
S
(cd "$ROOT" && git add -A && git_q commit -qm 'point sources at the local upstream')
echo "$base" > "$W/base"
