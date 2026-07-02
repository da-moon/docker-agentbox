#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

case "${1:-}" in
  "")
    args=()
    ;;
  --check | --no-build | --rehash)
    [ "$#" -eq 1 ] || {
      echo "update-all.sh accepts at most one of --check, --no-build, or --rehash." >&2
      exit 2
    }
    args=("$1")
    ;;
  *)
    echo "Usage: scripts/update-all.sh [--check|--no-build|--rehash]" >&2
    echo "Use an individual updater for --version VERSION." >&2
    exit 2
    ;;
esac

status=0
for updater in \
  update-claude-code.sh \
  update-codex.sh \
  update-hunk.sh \
  update-goose.sh \
  update-omp.sh \
  update-kimi-cli.sh \
  update-fff-mcp.sh \
  update-command-code.sh \
  update-gsd-2.sh; do
  if ! "${script_dir}/${updater}" "${args[@]}"; then
    status=1
  fi
done
exit "$status"
