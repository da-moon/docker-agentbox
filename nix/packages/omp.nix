{
  autoPatchelfHook,
  fetchurl,
  lib,
  stdenv,
  system,
}:
let
  version = "16.3.12";

  releaseBySystem = {
    x86_64-linux = {
      asset = "omp-linux-x64";
      hash = "sha256-x8sBV2xpbZa5bCHWkegpRRGb87u3MW4+ifxbF+IH27c=";
    };
    aarch64-linux = {
      asset = "omp-linux-arm64";
      hash = "sha256-96AcQhttqbKFqhO2xtjl84c0e7QbBH6LnCzxrM4gsJg=";
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
