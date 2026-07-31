{
  autoPatchelfHook,
  fetchurl,
  lib,
  stdenv,
  system,
}:
let
  version = "17.2.2";

  releaseBySystem = {
    x86_64-linux = {
      asset = "omp-linux-x64";
      hash = "sha256-MG9VVjfWPc7YDP+y/pCNp+BUOJ+FjAcfMEvBfj7WIt4=";
    };
    aarch64-linux = {
      asset = "omp-linux-arm64";
      hash = "sha256-BE5AXcNA0YYroaY00g7FxgCkDg7yQiG72z2zc7H+OtU=";
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
