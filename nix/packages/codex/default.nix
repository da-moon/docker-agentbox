{
  fetchurl,
  lib,
  stdenv,
  system,
  zstd,
}:
let
  version = "0.144.4";

  releaseBySystem = {
    aarch64-linux = {
      arch = "aarch64";
      hash = "sha256-FoBSwgYeEiVZJSKGcBS+sFVlmEVlIQzlEjA/fAb8jvk=";
    };
    x86_64-linux = {
      arch = "x86_64";
      hash = "sha256-HhzOCSO3OVZk8tmJAuaE4vpf5sWJ9Ggl6zT1fWpDkAI=";
    };
  };

  release = releaseBySystem.${system} or (throw "Unsupported system for codex: ${system}");
in
stdenv.mkDerivation {
  pname = "codex";
  inherit version;

  # The `-bundle` asset carries the sidecars the CLI expects to find beside
  # itself; the plain codex-*.tar.gz ships only `codex`.
  src = fetchurl {
    url = "https://github.com/openai/codex/releases/download/rust-v${version}/codex-${release.arch}-unknown-linux-musl-bundle.tar.zst";
    inherit (release) hash;
  };

  nativeBuildInputs = [ zstd ];

  sourceRoot = ".";
  dontBuild = true;
  dontConfigure = true;
  dontStrip = true;
  dontPatchELF = true;

  # codex resolves `codex-code-mode-host` and `codex-resources/bwrap` relative
  # to the realpath of its own executable, so both must sit next to bin/codex.
  installPhase = ''
    runHook preInstall
    install -Dm755 "codex" "$out/bin/codex"
    install -Dm755 "codex-code-mode-host" "$out/bin/codex-code-mode-host"
    install -Dm755 "codex-resources/bwrap" "$out/bin/codex-resources/bwrap"
    runHook postInstall
  '';

  meta = {
    description = "OpenAI Codex coding agent CLI";
    homepage = "https://github.com/openai/codex";
    license = lib.licenses.asl20;
    mainProgram = "codex";
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
  };
}
