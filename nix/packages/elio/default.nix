{
  autoPatchelfHook,
  fetchurl,
  lib,
  stdenv,
  system,
}:
let
  version = "1.11.2";

  releaseBySystem = {
    x86_64-linux = {
      target = "x86_64-unknown-linux-gnu";
      hash = "sha256-9cW/xUA9p0LEYI3/j4MGPVZvcyJpV1JYKYBuHur4sTM=";
    };
  };

  release = releaseBySystem.${system} or (throw "Unsupported system for elio: ${system}");
in
stdenv.mkDerivation {
  pname = "elio";
  inherit version;

  src = fetchurl {
    url = "https://github.com/elio-fm/elio/releases/download/v${version}/elio-${version}-${release.target}.tar.gz";
    inherit (release) hash;
  };

  sourceRoot = "elio-${version}-${release.target}";
  dontBuild = true;
  dontConfigure = true;
  dontStrip = true;

  nativeBuildInputs = [ autoPatchelfHook ];
  buildInputs = [ (lib.getLib stdenv.cc.cc) ];

  installPhase = ''
    runHook preInstall

    install -m755 -D elio $out/bin/elio

    mkdir -p $out/share/applications
    install -m644 packaging/linux/elio.desktop $out/share/applications/elio.desktop

    for size in 48 128 256 512; do
      mkdir -p $out/share/icons/hicolor/''${size}x''${size}/apps
      install -m644 packaging/linux/icons/hicolor/''${size}x''${size}/apps/elio.png \
        $out/share/icons/hicolor/''${size}x''${size}/apps/elio.png
    done

    runHook postInstall
  '';

  meta = {
    description = "Elio - snappy, batteries-included terminal file manager";
    homepage = "https://github.com/elio-fm/elio";
    license = lib.licenses.mit;
    mainProgram = "elio";
    platforms = [ "x86_64-linux" ];
  };
}
