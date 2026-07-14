cmd=$(basename "$0")
profile=$HOME/.local/state/nix/profiles/agentbox
bin=$profile/bin/$cmd

[ -x "$bin" ] && exec "$bin" "$@"

attr=$(jq -r --arg c "$cmd" '.[$c] // empty' "$manifest")
[ -n "$attr" ] || { echo "agentbox: '$cmd' is not a known harness" >&2; exit 127; }

mkdir -p "$(dirname "$profile")"
exec 9>"$(dirname "$profile")/.agentbox.lock"
flock 9
if [ ! -x "$bin" ]; then
  echo "agentbox: installing '$cmd' on first use (one-time)..." >&2
  nix profile add --profile "$profile" --no-write-lock-file "path:/opt/agentbox#$attr" \
    || { echo "agentbox: install of '$cmd' failed" >&2; exit 1; }
fi
exec 9>&-

exec "$bin" "$@"
