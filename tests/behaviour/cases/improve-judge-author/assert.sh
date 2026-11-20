. "$(dirname "$0")/../../lib.sh"
agent_ended
# The main agent ($MODEL) wrote the change: the judge is from the other family, at the main agent's effort.
effort="${MODEL##*:}"
case "$MODEL" in
  anthropic/*) own='anthropic/'; other='openai-codex/' ;;
  *) own='openai-codex/'; other='anthropic/' ;;
esac
has "$ORCA_LOG" "pi --model ${other}[^ :]+ --effort ${effort}( |\$)"
lacks "$ORCA_LOG" "pi --model $own"
