{
  autoPatchelfHook,
  fetchurl,
  lib,
  stdenv,
  system,
}:
let
  version = "1.44.0";

  releaseBySystem = {
    x86_64-linux = {
      asset = "goose-x86_64-unknown-linux-gnu.tar.gz";
      hash = "sha256-B/68i09zvf3D7OPTTQ4hsAXzpPQwCPlbhdZTjaj2usE=";
    };
    aarch64-linux = {
      asset = "goose-aarch64-unknown-linux-gnu.tar.gz";
      hash = "sha256-2mywBdQhsL3Lg/6Dhrpa6AYO8XrfZGQaaE1PxLnhwV8=";
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
