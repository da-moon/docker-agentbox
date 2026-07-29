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
docker run --detach -it --name "$(basename `pwd`)-agentbox" -e AGENT_UID="$(id -u)"  -e AGENT_GID="$(id -g)"  -v "$PWD:/workspace"  --env-file <(env | grep API_KEY)  -v "$(basename `pwd`)-agentbox-nix:/nix"  agentbox:latest
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
  -v "$name-nix:/nix" `
  agentbox:latest

Remove-Item $envFile -ErrorAction SilentlyContinue
```

> Keep in mind that the above snippet will pass in all env vars that contain
> `API_KEY` in their name to the image ; for safety , you might want to change
> that

On Windows and macOS, the snippet omits `AGENT_UID` and `AGENT_GID`; Docker
Desktop and podman machine map bind-mount ownership themselves. On Apple
Silicon, run an `arm64` image: build one locally with
`PLATFORMS=linux/arm64 ./scripts/build.sh`, or pull a multi-architecture tag
(`docker buildx imagetools inspect <image>` lists its platforms). Note that
`elio` ships x86_64 binaries only, so it has no shim on arm64.

Podman is a drop-in for the snippets above on Linux: use a fully qualified
image name (e.g. `docker.io/fjolsvin/agentbox:latest`) to skip the registry
prompt, and append `:z` to the workspace mount on SELinux distros
(`-v "$PWD:/workspace:z"`). Prefer a rootful setup (`podman machine set
--rootful` on macOS): the container must start as root and remap the agent
user onto the workspace owner, which rootless mode cannot do.

Attach a shell as the unprivileged `agent` user (its UID/GID match the
workspace owner thanks to `AGENT_UID`/`AGENT_GID`):

```bash
docker exec -u agent -it "$(basename `pwd`)-agentbox" bash -l
```

Root shells (without `-u agent`) work too, and `/workspace` is whitelisted in
git's `safe.directory`, so `git` and `nix develop` work there as root. Prefer
the agent user for daily use: harnesses first-installed from a root shell land
in the agent user's Nix profile as root-owned files.

> The snippets give each project its own `/nix` volume. Do not share one named
> `/nix` volume between concurrently running containers: every container runs
> its own nix-daemon, and two daemons on one store database is unsupported and
> can corrupt it. Reusing a volume across *sequential* runs of the same
> project is exactly what it is for.
>
> A reused volume also keeps the previous image's base profile (harness shims,
> the `agentbox` CLI, boot tools), hiding the newer image's `/nix`. At
> container start, `agentbox-setup` detects shims missing from the volume and
> refreshes the base profile from the current image automatically, so a
> rebuilt image works with an old volume.

- You can open a shell in the container with the following

Linux/macOS Bash:

```bash
docker exec -it "$(basename `pwd`)-agentbox" bash -l
```

Windows PowerShell 5:

```powershell
$name = "$(Split-Path -Leaf (Get-Location))-agentbox"
docker exec -it $name bash -l
```

- Exiting the shell leaves the container running; open as many concurrent
  shells as you like
- Avoid `docker attach`: its stdio stream is non-blocking, which crashes
  full-screen programs such as Zellij with a `WouldBlock` panic, and exiting
  the attached shell stops the container
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

## Process supervision

The container boots [s6-overlay](https://github.com/just-containers/s6-overlay)
as PID 1 (pinned in `nix/packages/s6-overlay/default.nix`). It runs nix-daemon
as a supervised service and restarts it automatically if it crashes or is
killed (for example by the OOM killer) — a dead daemon no longer means
restarting the container. Useful details:

- The daemon socket is container-local at `/run/nix-daemon/socket`
  (`NIX_DAEMON_SOCKET_PATH`), not on the `/nix` volume.
- Daemon logs go to `/var/log/nix-daemon/current` (rotated); nothing is lost
  when the daemon restarts.
- To restart the daemon by hand in a running container:

  ```bash
  docker exec -u root "$(basename `pwd`)-agentbox" /command/s6-svc -r /run/service/nix-daemon
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

## Managing harness versions

Harness versions are pinned in Nix (`nix/packages/<name>/default.nix`) and baked
into the image. To change them in a running container - update to the latest
release, or pin an older one - use the `agentbox` command, without rebuilding the
image:

```bash
agentbox list                  # pinned vs image-baseline versions, and what is installed
agentbox list --check          # also query each upstream project for its latest release
agentbox update claude-code    # update one harness to the latest release
agentbox update --all          # update every harness
agentbox pin claude-code 2.1.200  # install a specific (e.g. older) version
agentbox rollback              # revert the last change (previous profile generation)
agentbox reset claude-code     # restore the image-baseline version (--all for every harness)
```

`<name>` is a package attribute (`claude-code`, `kimi-cli`, `codex`, ...), not the
command name. Under the hood `agentbox` runs the same `scripts/update-<name>.sh`
updaters the repo uses - fetching the release, recomputing the Nix hashes, and
verifying the build - then installs the result into the per-user Nix profile that
takes precedence on `PATH`. `rollback` uses the Nix profile's previous generation,
so it undoes the most recent change; use `pin` to reach a specific older version.

Like the Home Manager flake, the mutable copy is seeded on first start: the boot
setup service clones the immutable image copy at `/opt/agentbox` to
`~/.config/agentbox/` (owned by the `agent` user) when it does not exist yet, so
`agentbox` edits and the installed versions survive restarts when the home
directory persists (for example on a volume). Delete `~/.config/agentbox` to
restore the image defaults on the next start, or use `agentbox reset`.

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
On first start the boot setup service (`agentbox-setup`, an s6 oneshot) copies
`nix/home-flake/flake.nix`,
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
  auto-updater, self-update, and installation checks off, and auto memory in the
  workspace (next section).
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
- Bash, coreutils, `sed`, CA certificates, UID/GID management, and `su-exec`
- s6-overlay as PID 1, supervising nix-daemon (see "Process supervision")
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
any shell that has `nix`. The s6-overlay pin in
`nix/packages/s6-overlay/default.nix` and the base image digest in the
Dockerfile are bumped manually, with fresh hashes.

## Repository layout

Nix is an implementation detail of the image, so all of it lives under `nix/`.
`nix/flake.nix` is the minimal image and package source, pinned to NixOS 26.05:
the Dockerfile builds `agentbox-base` from it and copies it to `/opt/agentbox`,
where the shims resolve harness installs at runtime. `nix/packages/*.nix` stays
as the package expression profile for custom flakes and update scripts;
`nix/packages/s6-overlay` fetches the pinned s6-overlay tarballs that the
Dockerfile merges into the image rootfs. `docker/rootfs/` holds the container
plumbing copied into the image: the s6 service definitions under
`etc/s6-overlay/s6-rc.d/` (the `nix-daemon` longrun with its log pipeline and
the `agentbox-setup` boot oneshot) and the `agentbox-init`/`agentbox-setup`/
`agentbox-cmd` wrappers under `usr/local/bin/`.
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
PLATFORMS=linux/amd64 ./scripts/build.sh   # single-arch, loads locally
./scripts/smoke-test.sh agentbox:latest
```

By default `scripts/build.sh` builds both `linux/amd64` and `linux/arm64` with
buildx and pushes (a multi-architecture image is a manifest list, which only
exists in a registry); point `IMAGE_NAME`/`IMAGE_TAG` at your repository
first. Building a foreign architecture on Linux needs QEMU binfmt, installed
once with `docker run --privileged --rm tonistiigi/binfmt --install all`.

Windows PowerShell 5:

```powershell
docker build --progress plain --tag agentbox:latest .
docker run --rm agentbox:latest bash -lc 'command -v hx && test "$EDITOR" = hx && command -v codex'
```

The full smoke test is a Bash script; run `./scripts/smoke-test.sh
agentbox:latest` from WSL or Git Bash on Windows.

The smoke test installs harnesses and startup packages for real, so it needs
network access. It uses a temporary Nix volume so the downloads happen once.
