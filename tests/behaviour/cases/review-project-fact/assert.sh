. "$(dirname "$0")/../../lib.sh"
agent_ended
log="$JSTACK_DATA/logs/review-log.md"; mem="$W/memory"
new="$(grep -vxFf "$W/log.before" "$log")"
[ -n "$new" ] || fail "review wrote no observation"
field() { awk -F' [|] ' -v n="$1" '{ print $n }'; }
# The new line that reads applied for a page of the memory, given as the page's file.
applied_for() { printf '%s\n' "$new" | grep -E " [|] applied [0-9]{4}-[0-9]{2}-[0-9]{2} memory:${1#"$mem"/}\$" | head -1; }

# Each new fact is a page of the project's memory with its detail, and its line reads applied in a category that holds facts.
shell_page="$(grep -rlF 'deployctl console' "$mem" 2>/dev/null | head -1)"
[ -n "$shell_page" ] || fail "no memory page holds the shell command: $(tail -3 "$W/memory.log" 2>/dev/null)"
# The launch state is the only other new fact of the run: its page is the one beside the shell command and the seeded domain.
launch_page="$(find "$mem" -type f ! -name canonical-domain.md | grep -vxF "$shell_page" | head -1)"
[ -n "$launch_page" ] || fail "no memory page holds the launch state: $(ls "$mem/facts" 2>/dev/null)"
for page in "$shell_page" "$launch_page"; do
  line="$(applied_for "$page")"
  [ -n "$line" ] || fail "no new line reads applied for ${page#"$mem"/}: $new"
  case "$(printf '%s\n' "$line" | field 4)" in navigation | lesson) ;; *) fail "a saved fact is in another category: $line" ;; esac
done
# The shared log holds no project detail: it is in the pages.
detail="$(printf '%s\n' "$new" | grep -Ei 'deployctl|shop-web|shop\.example' | head -1)"
[ -z "$detail" ] || fail "a log line holds project detail: $detail"

# Two more observations stay open: the gap of the event that also holds a fact, under another tag than its fact, and the stalled
# worker, which holds no fact. No line reads applied for the stalled worker.
others="$(printf '%s\n' "$new" | awk -F' [|] ' '$8 == "open" && $5 != "canonical-domain"')"
[ "$(printf '%s\n' "$others" | grep -c .)" -ge 2 ] || fail "want an open line for the gap in the size step and one for the stalled worker, got: ${others:-none}"
launch_tag="$(applied_for "$launch_page" | field 5)"
if printf '%s\n' "$others" | awk -F' [|] ' -v t="$launch_tag" '$5 == t { f = 1 } END { exit !f }'; then fail "the fact and its gap share the tag $launch_tag"; fi
stall="$(printf '%s\n' "$new" | awk -F' [|] ' '$7 == "evidence/verifier-stall.txt" && $8 != "open"')"
[ -z "$stall" ] || fail "the stalled worker is not open: $stall"

# A fact whose tag reads applied in this repo: its line takes the tag and stays open, and no page is written for it.
dom="$(printf '%s\n' "$new" | awk -F' [|] ' '$5 == "canonical-domain"')"
[ -n "$dom" ] || fail "no new observation takes the tag canonical-domain: $new"
if printf '%s\n' "$dom" | grep -vq ' | open$'; then fail "the fact with an applied tag is not open: $dom"; fi
same_file "$W/domain-page.before" "$mem/facts/canonical-domain.md"
again="$(grep -rlF 'shop.example.com' "$mem" | grep -v '/canonical-domain\.md$' | head -1)"
[ -z "$again" ] || fail "the fact with an applied tag was saved again: ${again#"$mem"/}"

# The closing line names the tag that is open again, on the day of its applied line too, and a saved page. The logs are pushed.
has .cookbook/dishes/orders-export/ledger.md '^phase: done'
page="${shell_page#"$mem"/}"
awk -v p="$page" 'index($0, "canonical-domain") && index($0, p) && index($0, "/improve") { f = 1 } END { exit !f }' "$OUT" ||
  fail "no line of the reply names the tag canonical-domain, the saved page $page and /improve: $(tail -3 "$OUT")"
pushed review-log.md ' [|] applied [0-9-]+ memory:facts/'
