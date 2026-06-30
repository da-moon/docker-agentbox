# docker-agentbox

A Docker-based Linux sandbox for coding agents. The image starts from the
official Nix image and uses this repository's flake to provision Claude Code,
Codex, Hunk, and a focused set of development tools.

Nix provisions the image; it does not build the Docker image.

## Build

```bash
./scripts/build.sh
```

This creates `agentbox:latest`. Override the name or tag with `IMAGE_NAME` and
`IMAGE_TAG`, and pass additional Docker flags after the script name:

```bash
IMAGE_TAG=dev ./scripts/build.sh --no-cache
```

The Dockerfile pins the multi-architecture `nixos/nix:2.34.7` manifest digest.
Native `linux/amd64` and `linux/arm64` builds select their corresponding image
and package releases.

## Run

```bash
docker run --rm -it \
  -v "$PWD:/workspace" \
  -e ANTHROPIC_API_KEY \
  -e OPENAI_API_KEY \
  agentbox:latest
```

The default runtime identity is `agent` with UID/GID 1000. The entrypoint runs
`nix-daemon` as root and then drops privileges, so agents can use `nix build`,
`nix shell`, and user-scoped `nix profile install` without running as root.

Match host ownership when mounting a workspace:

```bash
docker run --rm -it \
  -e AGENT_UID="$(id -u)" \
  -e AGENT_GID="$(id -g)" \
  -v "$PWD:/workspace" \
  agentbox:latest
```

Use root explicitly when a task requires it:

```bash
docker run --rm -it -e AGENT_RUN_AS_ROOT=1 agentbox:latest
```

Do not use Docker's `--user` option: the entrypoint must initially run as root
to start `nix-daemon` and apply UID/GID mapping.

Credentials and agent state should be passed as environment variables or
mounted at runtime; they are not copied into the image.

## Included tools

- Agent harnesses: `claude`, `codex`
- Agent utilities: `hunk`, `rg`, `fd`, `sd`, `jq`, `yq`, `bat`, `fzf`,
  `delta`, `difft`
- Git/network: Git, Git LFS, GitHub CLI, OpenSSH, curl, wget
- Runtimes: Node.js, Bun, Python, uv
- Native builds: GCC, Make, CMake, pkg-config
- Formatting/linting: Biome, Prettier, ShellCheck, shfmt, nixfmt
- Standard Unix, archive, patch, and file utilities

The flake exposes `agentbox-env`, `claude-code`, `codex`, and `hunk` packages.

## Updating

Check all embedded agent packages:

```bash
./scripts/update-all.sh --check
```

Update all packages to their latest releases:

```bash
./scripts/update-all.sh
```

Each updater also supports `--version VERSION`, `--rehash`, and `--no-build`:

```bash
./scripts/update-codex.sh --version 0.140.0
```

Update the pinned nixpkgs input separately:

```bash
./scripts/update-lock.sh
```

Updater scripts edit package versions and architecture-specific hashes, verify
the affected Nix package by default, and never create Git commits.

## Verification

```bash
nix flake check path:.
./scripts/build.sh
./scripts/smoke-test.sh agentbox:latest
```
