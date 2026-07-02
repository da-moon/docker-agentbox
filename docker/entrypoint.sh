#!/usr/bin/env bash
set -euo pipefail

readonly AGENT_USER="agent"
readonly AGENT_HOME="/home/${AGENT_USER}"
readonly WORKSPACE="/workspace"
readonly DAEMON_SOCKET="/nix/var/nix/daemon-socket/socket"
readonly DAEMON_LOG="/tmp/nix-daemon.log"

requested_uid="${AGENT_UID:-1000}"
requested_gid="${AGENT_GID:-1000}"

is_unsigned_integer() {
  [[ "$1" =~ ^[0-9]+$ ]]
}

if [ "$(id -u)" -ne 0 ]; then
  echo "agentbox-entrypoint must start as root so it can launch nix-daemon and remap the runtime UID/GID; it drops to the unprivileged agent user before running anything." >&2
  echo "Do not use docker run --user." >&2
  exit 1
fi

if ! is_unsigned_integer "$requested_uid" || ! is_unsigned_integer "$requested_gid"; then
  echo "AGENT_UID and AGENT_GID must be non-negative integers." >&2
  exit 2
fi

if [ "$requested_uid" = "0" ] || [ "$requested_gid" = "0" ]; then
  echo "The container always runs unprivileged; AGENT_UID and AGENT_GID must be non-zero." >&2
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

# Home Manager owns the per-user environment: the startup packages and the
# seeded harness defaults, defined by the flake template in
# /opt/agentbox/home-flake. The template is copied to ~/.config/home-manager
# on first start so the user owns it and can evolve it with plain
# `home-manager switch`. AGENTBOX_HM_FLAKE skips the copy and applies a
# user-provided flake reference instead.
apply_home_manager() {
  case "$(uname -m)" in
  x86_64) hm_system="x86_64-linux" ;;
  aarch64) hm_system="aarch64-linux" ;;
  *)
    echo "agentbox: unsupported architecture for home-manager (skipping)" >&2
    return 0
    ;;
  esac
  flake_ref="${AGENTBOX_HM_FLAKE:-$AGENT_HOME/.config/home-manager}"
  if [ -z "${AGENTBOX_HM_FLAKE:-}" ]; then
    su-exec "$1" env HOME="$AGENT_HOME" AGENTBOX_SYSTEM="$hm_system" sh -c '
      [ -e "$HOME/.config/home-manager/flake.nix" ] && exit 0
      mkdir -p "$HOME/.config/home-manager"
      install -m 0644 /opt/agentbox/home-flake/home.nix "$HOME/.config/home-manager/home.nix"
      install -m 0644 /opt/agentbox/home-flake/flake.lock "$HOME/.config/home-manager/flake.lock"
      sed "s/@AGENTBOX_SYSTEM@/$AGENTBOX_SYSTEM/" /opt/agentbox/home-flake/flake.nix \
        >"$HOME/.config/home-manager/flake.nix"
    ' || echo "agentbox: home-manager template install failed (continuing)" >&2
  fi
  su-exec "$1" env HOME="$AGENT_HOME" USER="$AGENT_USER" NIX_REMOTE=daemon \
    home-manager switch -b backup --flake "$flake_ref" ||
    echo "agentbox: home-manager switch failed (continuing)" >&2
}

export HOME="$AGENT_HOME"
export USER="$AGENT_USER"
export LOGNAME="$AGENT_USER"
apply_home_manager "${requested_uid}:${requested_gid}"

exec tini -- su-exec "${requested_uid}:${requested_gid}" "$@"
