# docker-agentbox

A Docker sandbox for coding agents, built on the official Nix image. The
published image stays small: it bakes only the boot tools and lazy harness
shims, provisions the common toolset with Home Manager when the container
starts, and installs each agent harness the first time you run it. Nothing
agent-specific is baked in, so an image you use only for Codex never pulls
Claude Code.

## Build

Linux/macOS Bash:

```bash
./scripts/build.sh
```

Windows PowerShell 5:

```powershell
docker build --progress plain --tag agentbox:latest .
```

This builds `agentbox:latest`. Override the name or tag with `IMAGE_NAME` and
`IMAGE_TAG`, and pass extra Docker flags after the script name:

Linux/macOS Bash:

```bash
IMAGE_TAG=dev ./scripts/build.sh --no-cache
```

Windows PowerShell 5:

```powershell
docker build --progress plain --tag agentbox:dev --no-cache .
```

The Dockerfile pins the multi-architecture `nixos/nix:2.34.7` digest, so native
`linux/amd64` and `linux/arm64` builds select the matching image and binaries.

## Run

- Start a containerized environment for your directory

Linux/macOS Bash:

```bash
docker run --detach -it --name "$(basename `pwd`)-agentbox" -e AGENT_UID="$(id -u)"  -e AGENT_GID="$(id -g)"  -v "$PWD:/workspace"  --env-file <(env | grep API_KEY)  -v agentbox-nix:/nix  agentbox:latest
```

Windows PowerShell 5:

```powershell
$name = "$(Split-Path -Leaf (Get-Location))-agentbox"
$envFile = Join-Path $env:TEMP "$name.env"
$apiEnv = Get-ChildItem Env:* | Where-Object { $_.Name -like "*API_KEY*" } | ForEach-Object { "{0}={1}" -f $_.Name, $_.Value }
New-Item -ItemType File -Force -Path $envFile | Out-Null
if ($apiEnv) {
  Set-Content -Encoding ASCII -Path $envFile -Value $apiEnv
}

docker run --detach -it --name $name `
  -v "${PWD}:/workspace" `
  --env-file $envFile `
  -v agentbox-nix:/nix `
  agentbox:latest

Remove-Item $envFile -ErrorAction SilentlyContinue
```

> Keep in mind that the above snippet will pass in all env vars that contain
> `API_KEY` in their name to the image ; for safety , you might want to change
> that

On Windows, the snippet omits `AGENT_UID` and `AGENT_GID`; Docker Desktop
handles bind mount permissions differently from Linux.

- You can attach to the container with the following

Linux/macOS Bash:

```bash
docker attach "$(basename `pwd`)-agentbox"
```

Windows PowerShell 5:

```powershell
$name = "$(Split-Path -Leaf (Get-Location))-agentbox"
docker attach $name
```

- To detach safely, press `Ctrl+P`, then `Ctrl+Q`
- You can remove the container by running the following

Linux/macOS Bash:

```bash
docker rm -f "$(basename `pwd`)-agentbox"
```

Windows PowerShell 5:

```powershell
$name = "$(Split-Path -Leaf (Get-Location))-agentbox"
docker rm -f $name
```

## Running a harness

Type the harness you want. The first run installs it, then hands off to it:

```bash
codex --version      # installs codex, then runs it
claude               # installs claude, then runs it
goose --help
omp --help
hunk --help
elio --help          # x86_64-linux only
```

The image ships shims for `claude`, `codex`, `goose`, `omp`, `hunk`, `elio` (x86_64-linux
only), `kimi`, `command-code`, `gsd`, and `fff-mcp`, and fetches only the one you run.

## Customizing a Harness from host

- Copy host's hooks into the harness

```bash
# Claude Code
# Kimi Code
# Codex
```

These snippets copy the hook scripts; you need to get a shell into container, run the harness and ask the agents to patch and update their own config so that hooks are setup properly

## Home Manager

The per-user environment inside the container is a Home Manager configuration.
On first start the entrypoint copies `nix/home-flake/flake.nix`,
`nix/home-flake/flake.lock`, and `nix/home-flake/programs/` to
`~/.config/home-manager/` - owned by the `agent` user - and applies it with
`home-manager switch -b backup --flake ~/.config/home-manager#agent`. It
installs the startup packages and seeds the harness defaults below. Helix is
installed by default, and `EDITOR`/`VISUAL` are set to `hx`.
Atuin, Zellij, Helix, Bat, Fzf, Ripgrep, and Jq are enabled with Home Manager
`programs.*` modules under `~/.config/home-manager/programs/` so their config
can be managed in the copied flake. The default flake intentionally manages
tool config only for the generated runtime files
`~/.config/helix/config.toml`, `~/.config/helix/languages.toml`, and
`~/.config/zellij/config.kdl`; their source of truth is native Nix in
`~/.config/home-manager/programs/helix-settings.nix`,
`~/.config/home-manager/programs/helix-languages.nix`, and
`~/.config/home-manager/programs/zellij-settings.nix`. Zellij is installed but
not auto-started; enable its shell integration in the copied flake if you want
that behavior.

The default package source is NixOS 26.05. The copied flake also pins
`nixos-unstable` as `pkgsUnstable`, so you can opt individual packages into
unstable without changing the whole environment. The seeded
`home.stateVersion` follows the Home Manager release branch, currently 26.05.

In a long-running container this is how you evolve the environment without
rebuilding the image:

```bash
$EDITOR ~/.config/home-manager/flake.nix                  # package list, harness defaults
$EDITOR ~/.config/home-manager/programs/helix-settings.nix # native Helix settings
$EDITOR ~/.config/home-manager/programs/zellij-settings.nix # native Zellij settings
hm-switch
```

Use `hm-update` to update the copied flake's inputs and immediately switch to
the result.

The copy is made only when `~/.config/home-manager/flake.nix` does not exist
yet, so your edits survive restarts when the home directory persists (for
example on a volume). Conflicting dotfiles are moved aside with a `.backup`
extension.

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

Linux/macOS Bash:

```bash
slug="$(printf '%s' "$PWD" | sed 's/[^A-Za-z0-9]/-/g')"
mem="$HOME/.claude/projects/$slug/memory"
mkdir -p .claude "$HOME/.claude/projects/$slug"
[ -d "$mem" ] && [ ! -L "$mem" ] && [ ! -e .claude/memory ] && mv "$mem" .claude/memory
mkdir -p .claude/memory
ln -sfn "$PWD/.claude/memory" "$mem"
```

Windows PowerShell 5:

```powershell
$project = (Get-Location).Path
$slug = $project -replace '[^A-Za-z0-9]', '-'
$repoClaude = Join-Path $project ".claude"
$repoMem = Join-Path $repoClaude "memory"
$mem = Join-Path $HOME ".claude\projects\$slug\memory"

New-Item -ItemType Directory -Force -Path $repoClaude | Out-Null
New-Item -ItemType Directory -Force -Path (Split-Path $mem -Parent) | Out-Null

if (Test-Path $mem) {
  $item = Get-Item $mem -Force
  $isLink = [bool]($item.Attributes -band [IO.FileAttributes]::ReparsePoint)
  if ($item.PSIsContainer -and -not $isLink -and -not (Test-Path $repoMem)) {
    Move-Item $mem $repoMem
  }
}

New-Item -ItemType Directory -Force -Path $repoMem | Out-Null
if (Test-Path $mem) {
  Remove-Item $mem -Recurse -Force
}
New-Item -ItemType SymbolicLink -Path $mem -Target $repoMem | Out-Null
```

If the PowerShell symlink command fails, enable Windows Developer Mode or run
PowerShell as Administrator.

Add `.claude/memory/` to the project's `.gitignore` to keep the memory
machine-local, or commit it to carry it with the repo. Do not point a
`.claude/settings.local.json` inside the repo at a host path: in the container
that file outranks the seeded default and the path does not exist there.

## What is in the image

Baked in:

- Nix and Home Manager
- Bash, coreutils, `sed`, CA certificates, UID/GID management, `su-exec`, and
  `tini`
- Lazy shims for the agent harnesses

Installed into the container at startup by Home Manager:

- Search and files: `rg`, `fd`, `sd`, `jq`, `yq`, `bat`, `fzf`, `delta`,
  `tree`, Helix
- Shell/session tools: Atuin and Zellij
- Git and network: Git, Git LFS, GitHub CLI, GitLab CLI, SourceHut CLI,
  OpenSSH, curl, wget
- Shell tooling: ShellCheck, shfmt, nixfmt, and the usual Unix, archive, and
  file utilities
- Development tools: Node.js, Bun, Python, uv, GCC, Make, CMake, pkg-config,
  Biome, Prettier, difftastic

Change this set by editing `programs.*` modules under
`~/.config/home-manager/programs/` and `home.packages` in
`~/.config/home-manager/flake.nix` inside the container. Editing
`nix/home-flake/flake.nix` and `nix/home-flake/programs/` in this repo changes
the template for new containers.

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

Each updater also accepts `--version VERSION`, `--tag TAG`, `--rehash`, and `--no-build`:

```bash
./scripts/update-codex.sh --version 0.140.0
./scripts/update-omp.sh --tag v16.5.3
```

Update the pinned image/package flake inputs on their own:

```bash
nix flake update path:./nix
```

Update the Home Manager template inputs separately:

```bash
nix flake update path:./nix/home-flake
```

The `scripts/update-*.sh` helpers are Bash scripts. On Windows, run them from
WSL or Git Bash. The `nix flake update ...` commands use the same syntax from
any shell that has `nix`.

## Repository layout

Nix is an implementation detail of the image, so all of it lives under `nix/`.
`nix/flake.nix` is the minimal image and package source, pinned to NixOS 26.05:
the Dockerfile builds `agentbox-base` from it and copies it to `/opt/agentbox`,
where the shims resolve harness installs at runtime. `nix/packages/*.nix` stays
as the package expression profile for custom flakes and update scripts.
`nix/home-flake/` is the per-user Home Manager flake that ends up in
`~/.config/home-manager` inside the container; `programs/` contains one module
per enabled Home Manager program plus native Nix settings for the seeded Helix
and Zellij config.
It is pinned separately and also includes `nixos-unstable` for opt-in package
use. Building and running the image needs no nix on the host; only
`scripts/update-*.sh` and `nix flake check` use it, and the update scripts exit
before touching any file when nix is missing.

## Verification

Linux/macOS Bash:

```bash
nix flake check path:./nix
./scripts/build.sh
./scripts/smoke-test.sh agentbox:latest
```

Windows PowerShell 5:

```powershell
docker build --progress plain --tag agentbox:latest .
docker run --rm -v agentbox-nix:/nix agentbox:latest bash -lc 'command -v hx && test "$EDITOR" = hx && command -v codex'
```

The full smoke test is a Bash script; run `./scripts/smoke-test.sh
agentbox:latest` from WSL or Git Bash on Windows.

The smoke test installs harnesses and startup packages for real, so it needs
network access. It uses a temporary Nix volume so the downloads happen once.
