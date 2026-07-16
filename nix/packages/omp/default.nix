{
  autoPatchelfHook,
  fetchurl,
  lib,
  stdenv,
  system,
}:
let
  version = "17.0.0";

  releaseBySystem = {
    x86_64-linux = {
      asset = "omp-linux-x64";
      hash = "sha256-5fWlSniabyVL9bkxm86uMRUV2yroRu2YqhtsFmAKS8I=";
    };
    aarch64-linux = {
      asset = "omp-linux-arm64";
      hash = "sha256-0BueJJ+l3tNhqFEdbQbqyWU9g7bzQ6d64/JbIBzRAV4=";
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
