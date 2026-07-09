# docker-agentbox

A Docker sandbox for coding agents, built on the official Nix image. The
published image stays small. It ships a common toolset, installs each agent
harness the first time you run it, and installs the heavier development
packages when the container starts. Nothing agent-specific is baked in, so an
image you use only for Codex never pulls Claude Code.

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

- Start a containerized environment for your directory

```bash
docker run --detach -it --name "$(basename `pwd`)-agentbox" -e AGENT_UID="$(id -u)"  -e AGENT_GID="$(id -g)"  -v "$PWD:/workspace"  --env-file <(env | grep API_KEY)  -v agentbox-nix:/nix  agentbox:latest
```

> Keep in mind that the above snippet will pass in all env vars that contain
> `API_KEY` in their name to the image ; for safety , you might want to change
> that

- To detach safely, press `Ctrl+P`, then `Ctrl+Q`

- You can reattach to the container with the following

```bash
docker attach "$(basename `pwd`)-agentbox"
```

## Running a harness

Type the harness you want. The first run installs it, then hands off to it:

```bash
codex --version      # installs codex, then runs it
claude               # installs claude, then runs it
goose --help
omp --help
hunk --help
```

The image ships `claude`, `codex`, `goose`, `omp`, and `hunk`, and fetches only
the one you run.

## Home Manager

The per-user environment inside the container is a Home Manager configuration.
On first start the entrypoint copies the flake template from `nix/home-flake/`
to `~/.config/home-manager` — owned by the `agent` user, locked to the same
pins as the image — and applies it with `home-manager switch`. It installs the
startup packages and seeds the harness defaults below.

In a long-running container this is how you evolve the environment without
rebuilding the image:

```bash
$EDITOR ~/.config/home-manager/home.nix   # add packages, dotfiles, ...
home-manager switch
```

The copy is made only when `~/.config/home-manager/flake.nix` does not exist
yet, so your edits survive restarts when the home directory persists (for
example on a volume). Conflicting dotfiles are moved aside with a `.backup`
extension.

To bring your own configuration instead, point `AGENTBOX_HM_FLAKE` at a flake
reference with a `homeConfigurations.agent` entry (use
`~/.config/home-manager/flake.nix` from a running container as the shape to
copy); it replaces the built-in template, harness defaults included:

```bash
docker run ... -e AGENTBOX_HM_FLAKE="path:/workspace/hm#agent" agentbox:latest
```

## Harness defaults

The Home Manager configuration seeds a config file per harness at startup, only
when the file does not already exist; delete a file to get the default back on
the next start. The container is the sandbox, so approval prompts are off and
commit/PR attribution is disabled:

- `~/.claude/settings.json`: `bypassPermissions` mode, attribution off
  (including the session-URL trailer), always-on thinking at `xhigh` effort,
  auto-updater off, and auto memory in the workspace (next section).
- `~/.codex/config.toml`: `approval_policy = "never"`,
  `sandbox_mode = "danger-full-access"`, API-key auth preferred, commit
  attribution off.
- `~/.kimi-code/config.toml`: `default_permission_mode = "yolo"`; `tui.toml`
  turns the self-updater off (the binary is nix-pinned).
- `command-code` keeps no persistent config; pass `--yolo` when running it.

## Claude Code memory

Claude Code keeps its auto memory (the notes it writes itself) under
`~/.claude/projects/<project>/memory/`, and the container's home directory dies
with `--rm`. When `/workspace` is a bind mount, the seeded
`~/.claude/settings.json` therefore includes:

```json
{ "autoMemoryDirectory": "/workspace/.claude/memory" }
```

The memory then lands in the mounted project and survives the container.
Project, local, and `--settings` scopes all override the seeded file (the
setting needs Claude Code 2.1.74 or later; the image pins a newer one).
`CLAUDE.md`, `.claude/rules/`, and `CLAUDE.local.md` need no help: they live in
the repo and load on both sides already.

To have Claude Code on the host read and write the same memory, link the host's
default memory directory into the repo. Once, from the repo root:

```bash
slug="$(printf '%s' "$PWD" | sed 's/[^A-Za-z0-9]/-/g')"
mem="$HOME/.claude/projects/$slug/memory"
mkdir -p .claude "$HOME/.claude/projects/$slug"
[ -d "$mem" ] && [ ! -L "$mem" ] && [ ! -e .claude/memory ] && mv "$mem" .claude/memory
mkdir -p .claude/memory
ln -sfn "$PWD/.claude/memory" "$mem"
```

Add `.claude/memory/` to the project's `.gitignore` to keep the memory
machine-local, or commit it to carry it with the repo. Do not point a
`.claude/settings.local.json` inside the repo at a host path: in the container
that file outranks the seeded default and the path does not exist there.

## What is in the image

Baked in:

- Search and files: `rg`, `fd`, `sd`, `jq`, `yq`, `bat`, `fzf`, `delta`, `tree`
- Git and network: Git, Git LFS, GitHub CLI, OpenSSH, curl, wget
- Shell tooling: ShellCheck, shfmt, nixfmt, and the usual Unix, archive, and
  file utilities
- Nix and Home Manager, for the workflows above

Installed into the container at startup: Node.js, Bun, Python, uv, GCC, Make,
CMake, pkg-config, Biome, Prettier, difftastic. Change this set by editing
`home.packages` in `~/.config/home-manager/home.nix` inside the container
(`nix/home-flake/home.nix` in this repo changes the template for new
containers), or replace it entirely with `AGENTBOX_HM_FLAKE`.

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

Update the pinned flake inputs (nixpkgs and home-manager) on their own:

```bash
nix flake update path:./nix
```

## Repository layout

Nix is an implementation detail of the image, so all of it lives under `nix/`.
`nix/flake.nix` is the image's package source: the Dockerfile builds
`agentbox-base` from it and copies it to `/opt/agentbox`, where the shims
resolve harness installs at runtime. `nix/home-flake/` is the separate per-user
flake that ends up in `~/.config/home-manager` inside the container. Building
and running the image needs no nix on the host; only `scripts/update-*.sh` and
`nix flake check` use it, and the update scripts exit before touching any file
when nix is missing.

## Verification

```bash
nix flake check path:./nix
./scripts/build.sh
./scripts/smoke-test.sh agentbox:latest
```

The smoke test installs harnesses and startup packages for real, so it needs
network access. It uses a temporary Nix volume so the downloads happen once.
