cmd=$(basename "$0")
profile=$HOME/.local/state/nix/profiles/agentbox
bin=$profile/bin/$cmd

# Install from the user's mutable overlay flake when present (so the `agentbox`
# command can evolve the pins); fall back to the immutable image copy.
flake=${AGENTBOX_FLAKE:-$HOME/.config/agentbox}
[ -e "$flake/flake.nix" ] || flake=/opt/agentbox

[ -x "$bin" ] && exec "$bin" "$@"

attr=$(jq -r --arg c "$cmd" '.[$c] // empty' "$manifest")
[ -n "$attr" ] || { echo "agentbox: '$cmd' is not a known harness" >&2; exit 127; }

mkdir -p "$(dirname "$profile")"
exec 9>"$(dirname "$profile")/.agentbox.lock"
flock 9
if [ ! -x "$bin" ]; then
  echo "agentbox: installing '$cmd' on first use (one-time)..." >&2
  nix profile add --profile "$profile" --no-write-lock-file "path:$flake#$attr" \
    || { echo "agentbox: install of '$cmd' failed" >&2; exit 1; }
fi
exec 9>&-

exec "$bin" "$@"
