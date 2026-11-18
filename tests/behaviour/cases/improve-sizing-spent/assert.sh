. "$(dirname "$0")/../../lib.sh"
agent_ended
# The rejected change left a marker, so the second run found both misses spent and started no second judge.
has "$ROOT/overlays/sizing-log.md" 'signal=[Ss]hape \| rejected'
has "$ROOT/overlays/sizing-log.md" 'add-export .*missed=Shape'; has "$ROOT/overlays/sizing-log.md" 'fix-rounding .*missed=Shape'
[ "$(grep -c 'worker-start' "$ORCA_LOG")" -eq 1 ] || fail "judge starts: $(grep -c 'worker-start' "$ORCA_LOG"), want 1"
clean_tree "$ROOT"
