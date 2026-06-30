#!/usr/bin/env bash
set -euo pipefail

readonly AGENT_USER="agent"
readonly AGENT_HOME="/home/${AGENT_USER}"
readonly WORKSPACE="/workspace"
readonly DAEMON_SOCKET="/nix/var/nix/daemon-socket/socket"
readonly DAEMON_LOG="/tmp/nix-daemon.log"

requested_uid="${AGENT_UID:-1000}"
requested_gid="${AGENT_GID:-1000}"
run_as_root="${AGENT_RUN_AS_ROOT:-0}"

is_unsigned_integer() {
  [[ "$1" =~ ^[0-9]+$ ]]
}

if [ "$(id -u)" -ne 0 ]; then
  echo "agentbox-entrypoint must start as root so it can launch nix-daemon and select the runtime UID/GID." >&2
  echo "Use AGENT_RUN_AS_ROOT=1 for a root shell; do not use docker run --user." >&2
  exit 1
fi

if ! is_unsigned_integer "$requested_uid" || ! is_unsigned_integer "$requested_gid"; then
  echo "AGENT_UID and AGENT_GID must be non-negative integers." >&2
  exit 2
fi

if [ "$run_as_root" != "0" ] && [ "$run_as_root" != "1" ]; then
  echo "AGENT_RUN_AS_ROOT must be either 0 or 1." >&2
  exit 2
fi

if [ "$requested_uid" = "0" ] && [ "$run_as_root" != "1" ]; then
  echo "AGENT_UID=0 requires AGENT_RUN_AS_ROOT=1." >&2
  exit 2
fi

current_uid="$(id -u "$AGENT_USER")"
current_gid="$(id -g "$AGENT_USER")"

if [ "$current_gid" != "$requested_gid" ]; then
  groupmod --non-unique --gid "$requested_gid" "$AGENT_USER"
fi

if [ "$current_uid" != "$requested_uid" ]; then
  usermod --non-unique --uid "$requested_uid" --gid "$requested_gid" "$AGENT_USER"
elif [ "$current_gid" != "$requested_gid" ]; then
  usermod --gid "$requested_gid" "$AGENT_USER"
fi

mkdir -p "$AGENT_HOME" "$WORKSPACE" "$(dirname "$DAEMON_SOCKET")"
chown "$requested_uid:$requested_gid" "$AGENT_HOME" "$WORKSPACE"

export HOME=/root
export USER=root
export LOGNAME=root

rm -f "$DAEMON_SOCKET"
env -u NIX_REMOTE nix-daemon --daemon >"$DAEMON_LOG" 2>&1 &
nix_daemon_pid="$!"

for _ in $(seq 1 100); do
  if [ -S "$DAEMON_SOCKET" ]; then
    break
  fi
  if ! kill -0 "$nix_daemon_pid" 2>/dev/null; then
    wait "$nix_daemon_pid"
    cat "$DAEMON_LOG" >&2
    echo "nix-daemon exited before creating ${DAEMON_SOCKET}." >&2
    exit 1
  fi
  sleep 0.05
done

if [ ! -S "$DAEMON_SOCKET" ]; then
  cat "$DAEMON_LOG" >&2
  echo "Timed out waiting for nix-daemon socket at ${DAEMON_SOCKET}." >&2
  exit 1
fi

export NIX_REMOTE=daemon

install_extras() {
  su-exec "$1" env HOME="$2" NIX_REMOTE=daemon sh -c '
    mkdir -p "$HOME/.local/state/nix/profiles"
    nix profile install \
      --profile "$HOME/.local/state/nix/profiles/agentbox" \
      --no-write-lock-file \
      path:/opt/agentbox#agentbox-extras
  ' || echo "agentbox: extras install failed (continuing)" >&2
}

if [ "$run_as_root" = "1" ]; then
  export HOME=/root
  export USER=root
  export LOGNAME=root
  export PATH="/root/.local/state/nix/profiles/agentbox/bin:$PATH"
  install_extras "0:0" /root
  exec tini -- "$@"
fi

export HOME="$AGENT_HOME"
export USER="$AGENT_USER"
export LOGNAME="$AGENT_USER"
install_extras "${requested_uid}:${requested_gid}" "$AGENT_HOME"

exec tini -- su-exec "${requested_uid}:${requested_gid}" "$@"
