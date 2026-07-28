{
  autoPatchelfHook,
  fetchurl,
  lib,
  stdenv,
  system,
}:
let
  version = "17.1.8";

  releaseBySystem = {
    x86_64-linux = {
      asset = "omp-linux-x64";
      hash = "sha256-fuN/oqzcRh/ihvdn51OTp7rCUA/2ODuGNxQSH3PWEOQ=";
    };
    aarch64-linux = {
      asset = "omp-linux-arm64";
      hash = "sha256-wteeLk1mW1S73PehdKiSsDRs4bY6StX4v+lcXsgou2Y=";
    };
  };

  release = releaseBySystem.${system} or (throw "Unsupported system for omp: ${system}");
in
stdenv.mkDerivation {
  pname = "omp";
  inherit version;

  src = fetchurl {
    url = "https://github.com/can1357/oh-my-pi/releases/download/v${version}/${release.asset}";
    inherit (release) hash;
  };

  dontUnpack = true;
  dontBuild = true;
  dontConfigure = true;
  dontStrip = true;

  nativeBuildInputs = [ autoPatchelfHook ];
  buildInputs = [ (lib.getLib stdenv.cc.cc) ];

  installPhase = ''
    runHook preInstall
    install -Dm755 "$src" "$out/bin/omp"
    runHook postInstall
  '';

  meta = {
    description = "omp - AI coding agent CLI";
    homepage = "https://github.com/can1357/oh-my-pi";
    license = lib.licenses.mit;
    mainProgram = "omp";
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
  };
}
