. "$(dirname "$0")/../../lib.sh"
agent_ended
# The main agent ($MODEL) wrote the change: the judge is from the other family, at the main agent's effort.
effort="${MODEL##*:}"
case "$MODEL" in
  anthropic/*) own='anthropic/'; other='openai-codex/' ;;
  *) own='openai-codex/'; other='anthropic/' ;;
esac
s="$(worker_starts)"
[ -n "$s" ] || fail "no worker-start call: $(head -3 "$ORCA_LOG")"
printf '%s\n' "$s" | grep -Eq -- "--agent pi( |\$)" || fail "the judge is not started as a Pi agent: $s"
printf '%s\n' "$s" | grep -Eq -- "--model ${other}[^ :]+( |\$)" || fail "the judge's model is not from ${other}: $s"
printf '%s\n' "$s" | grep -Eq -- "--effort ${effort}( |\$)" || fail "the judge's effort is not ${effort}: $s"
if printf '%s\n' "$s" | grep -q -- "--model $own"; then fail "a judge from the author's family: $s"; fi
# Orca creates the terminal, so it closes it after the judge reports.
lacks "$ORCA_LOG" '(^| )terminal create( |$)'
