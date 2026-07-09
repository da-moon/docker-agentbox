{
  cacert,
  fetchurl,
  lib,
  makeWrapper,
  nodejs_22,
  stdenv,
  system,
}:
let
  pname = "command-code";
  version = "0.42.0";
  nodejs = nodejs_22;

  outputHashBySystem = {
    # scripts/update-command-code.sh managed hashes.
    aarch64-linux = lib.fakeHash;
    x86_64-linux = "sha256-ETtq+gQq+Z638zJ2ugQeYli8SqKIcdKePNQz5ahbsMk=";
  };

  npmDeps = stdenv.mkDerivation {
    name = "${pname}-${version}-npm-deps";

    src = fetchurl {
      url = "https://registry.npmjs.org/${pname}/-/${pname}-${version}.tgz";
      hash = "sha256-MeJnBNu8qbbuV4C2Zyt9nZa9iJ6JH1+1OJwVm1/RvCQ=";
    };

    nativeBuildInputs = [
      nodejs
      cacert
    ];

    dontPatchShebangs = true;
    outputHashAlgo = "sha256";
    outputHashMode = "recursive";
    outputHash =
      outputHashBySystem.${system} or (throw "Missing command-code npm hash for system: ${system}");

    buildPhase = ''
      runHook preBuild
      export HOME=$TMPDIR
      export npm_config_cache=$TMPDIR/.npm
      tar -xzf $src
      cd package
      ${nodejs}/bin/node <<'NODE'
      const fs = require("fs");
      const pkg = JSON.parse(fs.readFileSync("package.json", "utf8"));

      delete pkg.devDependencies;
      delete pkg.packageManager;

      function exactSpec(spec) {
        if (typeof spec !== "string") return spec;
        if (/^(file:|link:|workspace:|git\+|https?:)/.test(spec)) return spec;
        const bare = spec.match(/^[~^](\d+\.\d+\.\d+(?:[-+][0-9A-Za-z.-]+)?)$/);
        return bare ? bare[1] : spec;
      }

      function isExactInstallSpec(spec) {
        return /^(file:|link:|workspace:|git\+|https?:)/.test(spec)
          || /^\d+\.\d+\.\d+(?:[-+][0-9A-Za-z.-]+)?$/.test(spec);
      }

      const unresolved = [];
      for (const field of ["dependencies", "devDependencies", "optionalDependencies"]) {
        for (const [name, spec] of Object.entries(pkg[field] || {})) {
          const next = exactSpec(spec);
          pkg[field][name] = next;
          if (typeof next === "string" && !isExactInstallSpec(next)) {
            unresolved.push(field + "." + name + "=" + next);
          }
        }
      }

      if (unresolved.length > 0) {
        throw new Error("Non-exact dependency specs remain: " + unresolved.join(", "));
      }

      fs.writeFileSync("package.json", JSON.stringify(pkg, null, 2) + "\n");
      NODE
      npm install --production --ignore-scripts --legacy-peer-deps
      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall
      mkdir -p $out
      cp -r . $out/
      runHook postInstall
    '';
  };
in
stdenv.mkDerivation {
  inherit pname version;

  src = npmDeps;

  nativeBuildInputs = [ makeWrapper ];

  dontBuild = true;
  dontConfigure = true;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/lib/${pname}
    mkdir -p $out/bin
    cp -r $src/* $out/lib/${pname}/

    for bin_name in cmd cmdc command-code commandcode; do
      makeWrapper ${nodejs}/bin/node $out/bin/$bin_name \
        --add-flags "$out/lib/${pname}/dist/index.mjs" \
        --set NODE_PATH "$out/lib/${pname}/node_modules" \
        --set NODE_ENV "production"
    done

    runHook postInstall
  '';

  meta = {
    description = "Command Code - coding agent that continuously learns your taste";
    homepage = "https://github.com/CommandCodeAI/command-code";
    license = lib.licenses.unfree;
    mainProgram = "command-code";
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
  };
}
