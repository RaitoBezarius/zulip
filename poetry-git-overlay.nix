{ pkgs }:
self: super: {

  talon-core = super.talon-core.overridePythonAttrs (
    _: {
      src = pkgs.fetchgit {
        url = "https://github.com/zulip/talon";
        rev = "137ea31ca506069f9a8bbddde0d0174f395a6893";
        sha256 = "0az75v71rphb1g4lzhlcmyk01xlmqn13m0h750la63zi00xgq1pb";
      };
      sourceRoot = "talon-137ea31/talon-core";
      buildInputs = [ self.setuptools ];
    }
  );

  zulip = super.zulip.overridePythonAttrs (
    _: {
      src = pkgs.fetchgit {
        url = "https://github.com/zulip/python-zulip-api";
        rev = "d26416a1e79fabddf392bd4a528381305519fe52";
        sha256 = "1hg4xkg4skzfm1ns4dn6fygmfs65gz7fhz0ia150fhs3yibsp5b7";
    };
    sourceRoot = "python-zulip-api-d26416a/zulip";
    format = "setuptools";
    }
  );

  zulip-bots = super.zulip-bots.overridePythonAttrs (
    _: {
      src = pkgs.fetchgit {
        url = "https://github.com/zulip/python-zulip-api";
        rev = "d26416a1e79fabddf392bd4a528381305519fe52";
        sha256 = "1hg4xkg4skzfm1ns4dn6fygmfs65gz7fhz0ia150fhs3yibsp5b7";
    };
    sourceRoot = "python-zulip-api-d26416a/zulip_bots";
    format = "setuptools";
    }
  );

}
