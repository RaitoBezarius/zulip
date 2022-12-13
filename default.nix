{ pkgs ? import <nixpkgs> { }, lib ? pkgs.lib, ... }:
let
  poetry2nix = pkgs.callPackage ../../nix-community/poetry2nix { };
  app = poetry2nix.mkPoetryApplication {
    projectDir = ./.;
    overrides = [
      (import ./poetry-git-overlay.nix { inherit pkgs; })
      (self: super: {
        # cryptography = super.cryptography.overridePythonAttrs (_: { overridePythonAttrs = _: super.cryptography; });
        pip = pkgs.python3.pkgs.pip.overrideAttrs
          (old: { postPatch = old.postPatch or ""; });
        py3dns = super.py3dns.overridePythonAttrs (old: {
          postPatch = ''
            substituteInPlace DNS/__init__.py --replace "Base._DiscoverNameServers()" ""
          '';
          buildInputs = old.buildInputs ++ [ self.setuptools ];
        });
        google-re2 = super.google-re2.overridePythonAttrs (old: {
          propagatedBuildInputs = old.propagatedBuildInputs
            ++ [ self.pybind11 pkgs.re2 ];
          # preferWheel = true;
        });
        disposable-email-domains =
          super.disposable-email-domains.overridePythonAttrs
          (old: { buildInputs = old.buildInputs ++ [ self.setuptools ]; });
        django-cte = super.django-cte.overridePythonAttrs
          (old: { buildInputs = old.buildInputs ++ [ self.setuptools ]; });
        jsx-lexer = super.jsx-lexer.overridePythonAttrs
          (old: { buildInputs = old.buildInputs ++ [ self.setuptools ]; });
        phonenumberslite = super.phonenumberslite.overridePythonAttrs
          (old: { buildInputs = old.buildInputs ++ [ self.setuptools ]; });
        mypy-boto3-ses = super.mypy-boto3-ses.overridePythonAttrs
          (old: { buildInputs = old.buildInputs ++ [ self.setuptools ]; });
        pyuca = super.pyuca.overridePythonAttrs
          (old: { buildInputs = old.buildInputs ++ [ self.setuptools ]; });
        python-gcm = super.python-gcm.overridePythonAttrs
          (old: { buildInputs = old.buildInputs ++ [ self.setuptools ]; });
        matrix-client = super.matrix-client.overridePythonAttrs
        (old: {
            prePatch = ''
                substituteInPlace setup.py --replace "pytest-runner~=5.1" "pytest-runner"
            '';
            buildInputs = old.buildInputs ++ [ self.setuptools self.pytest-runner ];
        });
        python-binary-memcached = super.python-binary-memcached.overridePythonAttrs
        (old: {
            preferWheel = true;
            postPatch = ''
                substituteInPlace setup.py \
                    --replace "from m2r import convert" "" \
                    --replace 'convert(read("CHANGELOG.md"))' '""'
            '';
            buildInputs = old.buildInputs ++ [ self.setuptools ];
        });
        django-bmemcached = super.django-bmemcached.overridePythonAttrs
        (old: {
            format = "setuptools";
        });
        django-sendfile2 = super.django-sendfile2.overridePythonAttrs
        (old: {
            format = "setuptools";
        });
        django-bitfield = super.django-bitfield.overridePythonAttrs
        (old: {
            format = "setuptools";
        });
        django-phonenumber-field = super.django-phonenumber-field.overridePythonAttrs
        (old: {
            buildInputs = old.buildInputs ++ [ self.setuptools self.setuptools-scm ];
        });
        django-two-factor-auth = super.django-two-factor-auth.overridePythonAttrs
        (old: {
            format = "setuptools";
            buildInputs = old.buildInputs ++ [ self.setuptools ];
        });
        openapi-core = super.openapi-core.overridePythonAttrs
        (old: {
            buildInputs = old.buildInputs ++ [ self.poetry-core ];
        });
        pyoembed = super.pyoembed.overridePythonAttrs
        (old: { buildInputs = old.buildInputs ++ [ self.setuptools ]; });
        sourcemap = super.sourcemap.overridePythonAttrs
          (old: { buildInputs = old.buildInputs ++ [ self.setuptools ]; });
        tlds = super.tlds.overridePythonAttrs (old: {
          buildInputs = old.buildInputs ++ [ self.setuptools ];
          postPatch = ''
            ls
              substituteInPlace setup.py \
                --replace " r = urllib.request.urlopen('https://data.iana.org/TLD/tlds-alpha-by-domain.txt')" "" \
                --replace "assert r.status == 200" "" \
                --replace "data = r.read().decode('utf-8').split('\n')" "data = open('${
                  ./tlds-alpha-by-domain.txt
                }', 'r').read().split('\n')"
          '';
      });
        scim2-filter-parser = super.scim2-filter-parser.overridePythonAttrs
          (old: {
            propagatedBuildInputs = old.propagatedBuildInputs
              ++ [ self.poetry ];
          });
        uhashring = super.uhashring.overridePythonAttrs
          (old: { buildInputs = old.buildInputs ++ [ self.hatchling ]; });
        django-statsd-mozilla = super.django-statsd-mozilla.overridePythonAttrs
          (old: { buildInputs = old.buildInputs ++ [ self.setuptools ]; });

      })
      pkgs.poetry2nix.defaultPoetryOverrides
    ];
    preferWheels = false;
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
