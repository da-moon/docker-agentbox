{
  autoPatchelfHook,
  fetchurl,
  lib,
  stdenv,
  system,
}:
let
  version = "0.24.1";

  releasePlatformBySystem = {
    x86_64-linux = "linux-x64";
    aarch64-linux = "linux-arm64";
  };

  binaryHashBySystem = {
    # scripts/update-kimi-cli.sh managed hashes.
    x86_64-linux = "sha256-5A1asqa4OKrN1HUVZBTUWWjWUCQkO7vO67xB7Yp5L4c=";
    aarch64-linux = "sha256-5eQSy+yB2IrbJWqcWjr6lfQUUSJD1UQ6fcO63QZ5jJI=";
  };

  releasePlatform =
    releasePlatformBySystem.${system} or (throw "Unsupported system for kimi-cli: ${system}");
  binaryHash =
    binaryHashBySystem.${system} or (throw "Missing kimi-cli hash for system: ${system}");
in
stdenv.mkDerivation {
  pname = "kimi-cli";
  inherit version;

  src = fetchurl {
    url = "https://code.kimi.com/kimi-code/binaries/${version}/kimi-code-${releasePlatform}";
    hash = binaryHash;
  };

  dontUnpack = true;
  dontBuild = true;
  dontConfigure = true;
  dontStrip = true;

  nativeBuildInputs = [ autoPatchelfHook ];
  buildInputs = [ stdenv.cc.cc.lib ];

  installPhase = ''
    runHook preInstall
    install -Dm755 "$src" "$out/bin/kimi"
    runHook postInstall
  '';

  meta = {
    description = "Kimi Code AI coding assistant CLI";
    homepage = "https://code.kimi.com";
    license = lib.licenses.asl20;
    mainProgram = "kimi";
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
  };
}
