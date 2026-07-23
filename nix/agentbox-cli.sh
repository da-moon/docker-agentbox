# agentbox: manage harness (claude-code, kimi-cli, codex, ...) versions inside a
# running container. The flake wrapper prepends `manifest=<path>` above this
# body; the manifest maps a command name to its package attr, for example
# {"claude":"claude-code"}.

profile="$HOME/.local/state/nix/profiles/agentbox"

# The mutable overlay flake is seeded to the home directory at container start.
# Fall back to the immutable image copy for read-only use before it is seeded.
flake="${AGENTBOX_FLAKE:-$HOME/.config/agentbox}"
[ -e "$flake/flake.nix" ] || flake="/opt/agentbox"
readonly profile flake
readonly baseline="/opt/agentbox"
readonly scripts="$flake/scripts"

usage() {
  cat <<'EOF'
Usage: agentbox <command> [args]

  list [--check]        Show pinned vs image-baseline versions
                        (--check also queries the upstream latest release).
  update <name>|--all   Update a harness (or all) to the latest release.
  pin <name> <version>  Install a specific, e.g. older, version of a harness.
  rollback              Revert to the previous profile generation.
  reset <name>|--all    Restore a harness (or all) to the image baseline.
  help                  Show this help.

<name> is a harness attribute such as claude-code, kimi-cli, or codex.
Changes live in the per-user profile and ~/.config/agentbox; they persist
across container restarts only when the home directory is a mounted volume.
EOF
}

harness_attrs() {
  jq -r 'to_entries[] | .value' "$manifest" | sort -u
}

command_for_attr() {
  jq -r --arg a "$1" 'to_entries[] | select(.value == $a) | .key' "$manifest" | head -n1
}

pin_version() {
  [ -e "$1" ] || return 0
  sed -n 's/^[[:space:]]*version = "\([^"]*\)";/\1/p' "$1" | head -n1
}

is_installed() {
  local cmd
  cmd="$(command_for_attr "$1")"
  [ -n "$cmd" ] && [ -e "$profile/bin/$cmd" ]
}

known_attr() {
  harness_attrs | grep -qxF "$1"
}

require_writable_overlay() {
  if [ "$flake" = "/opt/agentbox" ] || [ ! -w "$flake" ]; then
    echo "agentbox: overlay flake ~/.config/agentbox is missing or read-only; cannot change versions." >&2
    exit 1
  fi
}

install_or_upgrade() {
  local attr="$1"
  if is_installed "$attr"; then
    nix profile upgrade --profile "$profile" "$attr"
  else
    nix profile add --profile "$profile" --no-write-lock-file "path:$flake#$attr"
  fi
}

update_one() {
  local attr="$1"
  if [ ! -x "$scripts/update-$attr.sh" ]; then
    echo "agentbox: no updater for '$attr'" >&2
    return 1
  fi
  echo "agentbox: updating $attr to the latest release..."
  AGENTBOX_FLAKE_DIR="$flake" "$scripts/update-$attr.sh"
  install_or_upgrade "$attr"
  echo "agentbox: $attr is now $(pin_version "$flake/packages/$attr/default.nix")"
}

reset_one() {
  local attr="$1"
  local src="$baseline/packages/$attr/default.nix"
  local dst="$flake/packages/$attr/default.nix"
  if [ ! -e "$src" ]; then
    echo "agentbox: no image baseline for '$attr'" >&2
    return 1
  fi
  install -m 0644 "$src" "$dst"
  install_or_upgrade "$attr"
  echo "agentbox: $attr reset to baseline $(pin_version "$dst")"
}

cmd_list() {
  local check="false"
  if [ "${1:-}" = "--check" ]; then
    check="true"
  fi
  if [ "$check" = "true" ]; then
    printf '%-16s %-12s %-12s %-11s %s\n' HARNESS PINNED BASELINE UPSTREAM INSTALLED
  else
    printf '%-16s %-12s %-12s %s\n' HARNESS PINNED BASELINE INSTALLED
  fi
  local attr pinned base installed rc state
  while IFS= read -r attr; do
    pinned="$(pin_version "$flake/packages/$attr/default.nix")"
    base="$(pin_version "$baseline/packages/$attr/default.nix")"
    if is_installed "$attr"; then
      installed="yes"
    else
      installed="no"
    fi
    if [ "$check" = "true" ]; then
      state="-"
      if [ -x "$scripts/update-$attr.sh" ]; then
        rc=0
        AGENTBOX_FLAKE_DIR="$flake" "$scripts/update-$attr.sh" --check >/dev/null 2>&1 || rc=$?
        case "$rc" in
          0) state="current" ;;
          1) state="available" ;;
          *) state="?" ;;
        esac
      fi
      printf '%-16s %-12s %-12s %-11s %s\n' "$attr" "${pinned:--}" "${base:--}" "$state" "$installed"
    else
      printf '%-16s %-12s %-12s %s\n' "$attr" "${pinned:--}" "${base:--}" "$installed"
    fi
  done < <(harness_attrs)
}

cmd_update() {
  require_writable_overlay
  if [ "$1" = "--all" ]; then
    local attr status=0
    while IFS= read -r attr; do
      update_one "$attr" || status=1
    done < <(harness_attrs)
    return "$status"
  fi
  known_attr "$1" || {
    echo "agentbox: unknown harness '$1'" >&2
    exit 2
  }
  update_one "$1"
}

cmd_pin() {
  require_writable_overlay
  local attr="$1" version="${2:-}"
  if [ -z "$version" ]; then
    echo "agentbox: pin requires <name> <version>" >&2
    exit 2
  fi
  known_attr "$attr" || {
    echo "agentbox: unknown harness '$attr'" >&2
    exit 2
  }
  if [ ! -x "$scripts/update-$attr.sh" ]; then
    echo "agentbox: no updater for '$attr'" >&2
    exit 1
  fi
  echo "agentbox: pinning $attr to $version..."
  AGENTBOX_FLAKE_DIR="$flake" "$scripts/update-$attr.sh" --version "$version"
  install_or_upgrade "$attr"
  echo "agentbox: $attr pinned at $(pin_version "$flake/packages/$attr/default.nix")"
}

cmd_reset() {
  require_writable_overlay
  if [ "$1" = "--all" ]; then
    local attr status=0
    while IFS= read -r attr; do
      reset_one "$attr" || status=1
    done < <(harness_attrs)
    return "$status"
  fi
  known_attr "$1" || {
    echo "agentbox: unknown harness '$1'" >&2
    exit 2
  }
  reset_one "$1"
}

cmd_rollback() {
  nix profile rollback --profile "$profile"
  echo "agentbox: reverted to the previous profile generation"
}

main() {
  local sub="${1:-help}"
  if [ "$#" -gt 0 ]; then
    shift
  fi
  case "$sub" in
    list) cmd_list "${1:-}" ;;
    update)
      [ "$#" -ge 1 ] || {
        echo "agentbox: update requires <name> or --all" >&2
        exit 2
      }
      cmd_update "$1"
      ;;
    pin) cmd_pin "${1:-}" "${2:-}" ;;
    rollback) cmd_rollback ;;
    reset)
      [ "$#" -ge 1 ] || {
        echo "agentbox: reset requires <name> or --all" >&2
        exit 2
      }
      cmd_reset "$1"
      ;;
    help | --help | -h) usage ;;
    *)
      echo "agentbox: unknown command '$sub'" >&2
      usage >&2
      exit 2
      ;;
  esac
}

main "$@"
