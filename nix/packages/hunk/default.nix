{
  autoPatchelfHook,
  fetchurl,
  lib,
  stdenv,
  system,
}:
let
  version = "0.17.7";

  releaseBySystem = {
    x86_64-linux = {
      asset = "hunkdiff-linux-x64.tar.gz";
      sourceRoot = "hunkdiff-linux-x64";
      hash = "sha256-adR4jOV9SHLIErfyKy4t3/8ocRcznDNulVbcqCYOTE8=";
    };
    aarch64-linux = {
      asset = "hunkdiff-linux-arm64.tar.gz";
      sourceRoot = "hunkdiff-linux-arm64";
      hash = "sha256-/ZvprVB8kJNSQkxnf4pARfOgO+x9AkjsPYTXYGoaqgU=";
    };
  };

  release = releaseBySystem.${system} or (throw "Unsupported system for hunk: ${system}");
in
stdenv.mkDerivation {
  pname = "hunk";
  inherit version;

  src = fetchurl {
    url = "https://github.com/modem-dev/hunk/releases/download/v${version}/${release.asset}";
    inherit (release) hash;
  };

  inherit (release) sourceRoot;
  dontBuild = true;
  dontConfigure = true;
  dontStrip = true;

  nativeBuildInputs = [ autoPatchelfHook ];
  buildInputs = [ (lib.getLib stdenv.cc.cc) ];

  installPhase = ''
    runHook preInstall
    install -Dm755 hunk "$out/bin/hunk"
    runHook postInstall
  '';

  meta = {
    description = "AI-friendly diff review CLI";
    homepage = "https://github.com/modem-dev/hunk";
    license = lib.licenses.asl20;
    mainProgram = "hunk";
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
  };
}
