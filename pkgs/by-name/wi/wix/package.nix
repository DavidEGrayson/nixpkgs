{ lib, stdenv, mkShell, fetchgit, dotnetCorePackages, git, nuget-to-json }:
let
  pname = "wix";
  version = "6.0.2";
  src = fetchgit {
    url = "https://github.com/wixtoolset/wix";
    rev = "v${version}";
    hash = "sha256-6ii0VdSGuBVS4GL0W9I/sj694a0+Dg0xTKLxEQDwmGo=";
    leaveDotGit = true;
  };

  dotnet-sdk = dotnetCorePackages.sdk_8_0;

  wix = stdenv.mkDerivation rec {
    inherit pname version src;
    buildInputs = map dotnetCorePackages.fetchNupkg (lib.importJSON ./deps.json);
    nativeBuildInputs = [ dotnet-sdk git ];
    builder = ./builder.sh;
    meta = {
      description = "The most powerful set of tools available to create your Windows installation experience.";
      homepage = "https://www.firegiant.com/wixtoolset/";
      license = lib.licenses.msrl;
      maintainers = with lib.maintainers; [ ];
      mainProgram = "wix";
    };
  };

  update-deps = mkShell rec {
    inherit pname version src;
    nativeBuildInputs = [ dotnet-sdk git nuget-to-json ];
    dontConfigureNuget = true;
    shellHook = ''
      set -ue
      cd pkgs/by-name/wi/wix
      rm -rf tmp && mkdir -p tmp/build tmp/out
      export out=$PWD/tmp/out
      pushd tmp/build
      source ../../../wix/builder.sh
      popd > /dev/null
      nuget-to-json $NUGET_PACKAGES > deps.json
      echo "Updated deps.json"
      exit 0
    '';
  };
in
  wix // { inherit update-deps; }
