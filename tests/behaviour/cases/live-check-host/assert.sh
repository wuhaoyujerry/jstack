. "$(dirname "$0")/../../lib.sh"
agent_ended
# The session read the fact that review saved, and the first run of the check was on the host that the fact names.
has "$W/memory.log" '[|] read-page .*facts/canonical-domain'
[ -s "$W/live-calls" ] || fail "the live check did not run"
[ "$(head -1 "$W/live-calls")" = shop.example.com ] || fail "the first live check ran on $(head -1 "$W/live-calls"), not on the host of the saved fact"
