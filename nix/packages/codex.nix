{
  fetchurl,
  lib,
  stdenv,
  system,
}:
let
  version = "0.142.4";

  releaseBySystem = {
    aarch64-linux = {
      arch = "aarch64";
      hash = "sha256-pUbuBZFTE/6jQPgxW1T0PQd/Q5Cvu1ry3pRNSAE9RH8=";
    };
    x86_64-linux = {
      arch = "x86_64";
      hash = "sha256-8KxDdRxtOympc6hgqN5SitecsgzBKWYRkwo9XJHd75U=";
    };
  };

  release = releaseBySystem.${system} or (throw "Unsupported system for codex: ${system}");
in
stdenv.mkDerivation {
  pname = "codex";
  inherit version;

  src = fetchurl {
    url = "https://github.com/openai/codex/releases/download/rust-v${version}/codex-${release.arch}-unknown-linux-musl.tar.gz";
    inherit (release) hash;
  };

  sourceRoot = ".";
  dontBuild = true;
  dontConfigure = true;
  dontStrip = true;
  dontPatchELF = true;

  installPhase = ''
    runHook preInstall
    install -Dm755 "codex-${release.arch}-unknown-linux-musl" "$out/bin/codex"
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
