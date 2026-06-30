# docker-agentbox

A Docker sandbox for coding agents, built on the official Nix image. The
published image stays small. It ships a common toolset, installs each agent
harness the first time you run it, and installs the heavier development packages
when the container starts. Nothing agent-specific is baked in, so an image you
use only for Codex never pulls Claude Code.

## Build

```bash
./scripts/build.sh
```

This builds `agentbox:latest`. Override the name or tag with `IMAGE_NAME` and
`IMAGE_TAG`, and pass extra Docker flags after the script name:

```bash
IMAGE_TAG=dev ./scripts/build.sh --no-cache
```

The Dockerfile pins the multi-architecture `nixos/nix:2.34.7` digest, so native
`linux/amd64` and `linux/arm64` builds select the matching image and binaries.

## Run

```bash
docker run --rm -it \
  -e AGENT_UID="$(id -u)" \
  -e AGENT_GID="$(id -g)" \
  -v "$PWD:/workspace" \
  --env-file <(env | grep API_KEY) \
  -v agentbox-nix:/nix \
  agentbox:latest
```

- `AGENT_UID` and `AGENT_GID` map the container's `agent` user onto your host
  user, so files written under the mounted `/workspace` keep your ownership. Both
  default to `1000`. Do not pass Docker's `--user` flag: the entrypoint has to
  start as root to launch `nix-daemon` and remap the user. For a root shell, add
  `-e AGENT_RUN_AS_ROOT=1`.
- `--env-file <(env | grep API_KEY)` forwards your API keys at runtime instead of
  baking them into the image. Adjust the filter to whatever a harness needs, such
  as `ANTHROPIC_API_KEY` or `OPENAI_API_KEY`.
- `-v agentbox-nix:/nix` keeps the Nix store on a named volume. The startup
  packages and the harnesses then download once and are reused by later
  containers. Without it, every fresh `--rm` container downloads them again. Use
  a named volume rather than a bind mount; an empty directory mounted over `/nix`
  hides the store baked into the image.

## Running a harness

Type the harness you want. The first run installs it, then hands off to it:

```bash
codex --version      # installs codex, then runs it
claude               # installs claude, then runs it
hunk --help
```

The image ships `claude`, `codex`, and `hunk`, and fetches only the one you run.

## What is in the image

Baked in:

- Search and files: `rg`, `fd`, `sd`, `jq`, `yq`, `bat`, `fzf`, `delta`, `tree`
- Git and network: Git, Git LFS, GitHub CLI, OpenSSH, curl, wget
- Shell tooling: ShellCheck, shfmt, nixfmt, and the usual Unix, archive, and file
  utilities
- Nix, for the workflows below

Installed into the container at startup: Node.js, Bun, Python, uv, GCC, Make,
CMake, pkg-config, Biome, Prettier, difftastic. Change this set by editing the
`agentbox-extras` list in `flake.nix`.

## Project-specific tools

Mount a directory that has its own `flake.nix`, then pull its dependencies in
with a dev shell:

```bash
nix develop
```

This is where project-specific or heavy tooling belongs, including language
toolchains and MCP servers that should not live in the shared image.

## Updating

Check the agent packages against their upstreams:

```bash
./scripts/update-all.sh --check
```

Update them to the latest releases:

```bash
./scripts/update-all.sh
```

Each updater also accepts `--version VERSION`, `--rehash`, and `--no-build`:

```bash
./scripts/update-codex.sh --version 0.140.0
```

Update the pinned nixpkgs input on its own:

```bash
./scripts/update-lock.sh
```

## Verification

```bash
nix flake check path:.
./scripts/build.sh
./scripts/smoke-test.sh agentbox:latest
```

The smoke test installs harnesses and startup packages for real, so it needs
network access. It uses a temporary Nix volume so the downloads happen once.
