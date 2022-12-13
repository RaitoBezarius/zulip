{ pkgs ? import <nixpkgs> {}, lib ? pkgs.lib, ... }:
let
    app = pkgs.poetry2nix.mkPoetryApplication {
        projectDir = ./.;
        overrides = [
          (self: super:
            {
              cryptography = super.cryptography.overrideAttrs (_: { overridePythonAttrs = _: super.cryptography; });
            }
          )
          pkgs.poetry2nix.defaultPoetryOverrides
        ];
        preferWheels = true;
    };
    frontend = pkgs.buildNpmPackage {
      pname = "zulip-frontend";
      version = "6.0";

      nativeBuildInputs = [ pkgs.python3 ];

      src = ./.;
      npmDepsHash = "sha256-dQSCOAbrggyyysgajbhxBDlUtD0Lfw+5UgwMdd/RRco=";
      npmFlags = [ "--legacy-peer-deps" ];

      # TODO: run update-prod-static in fact.
      buildPhase = ''
        runHook preBuild

        ${pkgs.python3}/bin/python3 ./tools/webpack

        runHook postBuild
        '';

      PUPPETEER_SKIP_DOWNLOAD = 1;
    };
in {
    env = app.dependencyEnv;
    inherit frontend;
}
