{
  fetchurl,
  lib,
  stdenv,
  system,
}:
let
  version = "0.10.1";

  releaseBySystem = {
    x86_64-linux = {
      target = "x86_64-unknown-linux-musl";
      hash = "sha256-wXY3wzOvu73qSwPPPhVzJAxBR64SF1bjY6r6PJ0O+1g=";
    };
    aarch64-linux = {
      target = "aarch64-unknown-linux-musl";
      hash = "sha256-KiUBkQHuk3MyfavXrB1IAGOGiOlbZ7+zvsRBv42Tjyg=";
    };
  };

  release = releaseBySystem.${system} or (throw "Unsupported system for fff-mcp: ${system}");
in
stdenv.mkDerivation {
  pname = "fff-mcp";
  inherit version;

  src = fetchurl {
    url = "https://github.com/dmtrKovalenko/fff.nvim/releases/download/v${version}/fff-mcp-${release.target}";
    inherit (release) hash;
  };

  dontUnpack = true;
  dontBuild = true;
  dontConfigure = true;
  dontStrip = true;
  dontPatchELF = true;

  installPhase = ''
    runHook preInstall
    install -Dm755 "$src" "$out/bin/fff-mcp"
    runHook postInstall
  '';

  meta = {
    description = "FFF MCP server - fast, typo-resistant file search for AI agents";
    homepage = "https://github.com/dmtrKovalenko/fff";
    license = lib.licenses.mit;
    mainProgram = "fff-mcp";
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
  };
}
