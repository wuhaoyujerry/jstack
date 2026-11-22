. "$(dirname "$0")/../../lib.sh"
agent_ended
log="$ROOT/logs/review-log.md"
new="$(grep -vxFf "$W/log.before" "$log")"
# The observation of the missing interpreter link takes the tag and the category of the logged line with that cause.
link="$(printf '%s\n' "$new" | grep -Ei 'interpreter|environment|venv')"
[ -n "$link" ] || fail "review wrote no observation for the missing interpreter link: ${new:-no new line}"
printf '%s\n' "$link" | awk -F' [|] ' '$4 != "tool" || $5 != "lsp-worktree-env" { exit 1 }' || fail "want tool | lsp-worktree-env, got: $link"
pushed review-log.md ' [|] tool [|] lsp-worktree-env [|] .* [|] open$'
