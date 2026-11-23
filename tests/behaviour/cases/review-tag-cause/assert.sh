. "$(dirname "$0")/../../lib.sh"
agent_ended
log="$ROOT/logs/review-log.md"
new="$(grep -vxFf "$W/log.before" "$log")"
# The observation of the missing interpreter link takes the tag and the category of the logged line with that cause.
# Another line of the run is another observation: a fact that review saved from the same event, or another cause such as a
# failure that the ledger did not count.
printf '%s\n' "$new" | awk -F' [|] ' '$4 == "tool" && $5 == "lsp-worktree-env" && $8 == "open" { f = 1 } END { exit !f }' ||
  fail "review wrote no observation for the missing interpreter link as tool | lsp-worktree-env: ${new:-no new line}"
pushed review-log.md ' [|] tool [|] lsp-worktree-env [|] .* [|] open$'
