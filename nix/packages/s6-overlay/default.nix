{
  fetchurl,
  lib,
  stdenvNoCC,
  system,
}:
let
  version = "3.2.3.0";

  releaseBySystem = {
    x86_64-linux = {
      asset = "s6-overlay-x86_64.tar.xz";
      hash = "sha256-qT8CiCxu1Gsh5621wK3YYVTwEjbJPNgsfWgnIuiEBWM=";
    };
    aarch64-linux = {
      asset = "s6-overlay-aarch64.tar.xz";
      hash = "sha256-CVIFb/kTSCFjzDDjWy6US1B7oQJdePW+y7iTZ780RYE=";
    };
  };

  release = releaseBySystem.${system} or (throw "Unsupported system for s6-overlay: ${system}");

  tarball =
    name: hash:
    fetchurl {
      url = "https://github.com/just-containers/s6-overlay/releases/download/v${version}/${name}";
      inherit hash;
    };

  noarch = tarball "s6-overlay-noarch.tar.xz" "sha256-tyD52TQO/IuwdSi5dDgTyDbksC+Gk9kCQfBHmYtMU88=";
  arch = tarball release.asset release.hash;
in
stdenvNoCC.mkDerivation {
  pname = "s6-overlay";
  inherit version;

  # Not part of the agentbox profile: the Dockerfile copies this output
  # straight into the image rootfs (/init, /package, /command,
  # /etc/s6-overlay).
  srcs = [
    noarch
    arch
  ];
  dontUnpack = true;
  # The tarballs ship static binaries and portable scripts; keep the original
  # shebangs (e.g. /init's #!/bin/sh) instead of rewriting them to build-time
  # store paths that the final image does not carry.
  dontPatchShebangs = true;

  installPhase = ''
    runHook preInstall
    mkdir -p "$out"
    tar -xJf ${noarch} -C "$out"
    tar -xJf ${arch} -C "$out"
    runHook postInstall
  '';

  meta = {
    description = "s6-based process supervision and init system for containers";
    homepage = "https://github.com/just-containers/s6-overlay";
    license = lib.licenses.isc;
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
  };
}
