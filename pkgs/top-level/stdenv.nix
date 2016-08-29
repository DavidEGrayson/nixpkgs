{ system, bootStdenv, noSysDirs, config, crossSystem, platform, lib, allPackages }:

rec {
  allStdenvs = import ../stdenv {
    inherit system allPackages platform config lib crossStdenv;
  };

  defaultStdenv = allStdenvs.stdenv // { inherit platform; };

  crossStdenv = if crossSystem == null then null else
    import ../stdenv/cross {
      inherit crossSystem allPackages;
    };

  stdenv =
    if bootStdenv != null then
      bootStdenv // { inherit platform; }
    else if (config.replaceStdenv or null) != null then
      config.replaceStdenv {
        pkgs = allPackages {
          config = removeAttrs config [ "replaceStdenv" ];
        };
      }
    else
      defaultStdenv;
}
