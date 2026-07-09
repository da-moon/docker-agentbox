{
  autoPatchelfHook,
  fetchurl,
  lib,
  stdenv,
  system,
}:
let
  version = "1.41.0";

  releaseBySystem = {
    x86_64-linux = {
      asset = "goose-x86_64-unknown-linux-gnu.tar.gz";
      hash = "sha256-zY54RVc01ozEOrxtrOqOOK4AFg/BJFzpWcNVj9YYmKU=";
    };
    aarch64-linux = {
      asset = "goose-aarch64-unknown-linux-gnu.tar.gz";
      hash = "sha256-Cyy2rH3SeViX6q9hkGjaI2hp4RKIWEEhVeA8q7uUNI4=";
    };
  };

  release = releaseBySystem.${system} or (throw "Unsupported system for goose: ${system}");
in
stdenv.mkDerivation {
  pname = "goose";
  inherit version;

  src = fetchurl {
    url = "https://github.com/block/goose/releases/download/v${version}/${release.asset}";
    inherit (release) hash;
  };

  sourceRoot = ".";
  dontBuild = true;
  dontConfigure = true;
  dontStrip = true;

  nativeBuildInputs = [ autoPatchelfHook ];
  buildInputs = [ (lib.getLib stdenv.cc.cc) ];

  installPhase = ''
    runHook preInstall
    install -Dm755 goose "$out/bin/goose"
    runHook postInstall
  '';

  meta = {
    description = "Open-source AI agent for software development";
    homepage = "https://github.com/block/goose";
    license = lib.licenses.asl20;
    mainProgram = "goose";
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
  };
}
