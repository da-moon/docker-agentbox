{
  autoPatchelfHook,
  fetchurl,
  lib,
  makeWrapper,
  stdenv,
  system,
}:
let
  version = "2.1.205";

  releasePlatformBySystem = {
    x86_64-linux = "linux-x64";
    aarch64-linux = "linux-arm64";
  };

  binaryHashBySystem = {
    # scripts/update-claude-code.sh managed hashes.
    x86_64-linux = "sha256-3Yc0wLalA/4dF0JRhOV7OXwwuwM3oz8UcNmYX+v+Wwk=";
    aarch64-linux = "sha256-wYdMhbzTqItwQ5/VD/WRC35qxTccFN1J1MzCh4pZLQk=";
  };

  releasePlatform =
    releasePlatformBySystem.${system} or (throw "Unsupported system for claude-code: ${system}");
  binaryHash =
    binaryHashBySystem.${system} or (throw "Missing claude-code hash for system: ${system}");
in
stdenv.mkDerivation {
  pname = "claude-code";
  inherit version;

  src = fetchurl {
    url = "https://downloads.claude.ai/claude-code-releases/${version}/${releasePlatform}/claude";
    hash = binaryHash;
  };

  dontUnpack = true;
  dontBuild = true;
  dontConfigure = true;
  dontStrip = true;

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
  ];
  buildInputs = [ stdenv.cc.cc.lib ];

  installPhase = ''
    runHook preInstall

    install -Dm755 "$src" "$out/libexec/claude"

    makeWrapper "$out/libexec/claude" "$out/bin/claude" \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [ stdenv.cc.cc.lib ]} \
      --set DISABLE_INSTALLATION_CHECKS 1 \
      --set DISABLE_UPDATES 1 \
      --set DISABLE_UPGRADE_COMMAND 1 \
      --set DISABLE_AUTOUPDATER 1

    runHook postInstall
  '';

  meta = {
    description = "Claude Code AI coding assistant CLI";
    homepage = "https://code.claude.com/docs";
    license = lib.licenses.unfree;
    mainProgram = "claude";
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
  };
}
