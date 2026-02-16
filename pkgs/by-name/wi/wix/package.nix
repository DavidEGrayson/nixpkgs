{ lib, stdenv, pkgsCross, mkShell, fetchgit, dotnetCorePackages, git, nuget-to-json }:
let
  pname = "wix";
  version = "6.0.2";
  src = fetchgit {
    url = "https://github.com/wixtoolset/wix";
    rev = "v${version}";
    hash = "sha256-6ii0VdSGuBVS4GL0W9I/sj694a0+Dg0xTKLxEQDwmGo=";
    leaveDotGit = true;
  };
  patches = [ ./no_burn.patch ./dutil.patch ];

  dotnet-sdk = dotnetCorePackages.sdk_8_0;

  mingw_gcc = pkgsCross.ucrt64.stdenv.cc;

  #cross = pkgsCross.ucrt64;
  #mingw_gcc_patched = cross.stdenv.cc.cc.overrideAttrs (old: {
  #  postPatch = (old.postPatch or "") + ''
  #    echo "patching libstdc++ to avoid __in/__out"
  #    sed -i -E 's/\<__(in|out)\>/__stl_\1/g' libstdc++-v3/include/bits/stl_{algobase,pair}.h
  #  '';
  #});
  #mingw_gcc = cross.stdenv.cc.override {
  #  cc = mingw_gcc_patched;
  #};
  #old_mingw_gcc = pkgsCross.ucrt64.buildPackages.gcc.overrideAttrs (old:
  #  {
  #    postPatch = (old.postPatch or "") + ''
  #      echo hello running sed
  #      sed -E 's/\<__(in|out)\>/__stl_\1/g' src/libstdc++-v3/include/bits/stl_pair.h
  #    '';
  #  }
  #);

  wix = stdenv.mkDerivation rec {
    inherit pname version src patches;
    buildInputs = map dotnetCorePackages.fetchNupkg (lib.importJSON ./deps.json);
    nativeBuildInputs = [ dotnet-sdk git mingw_gcc ];
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
    inherit pname version src patches;
    nativeBuildInputs = wix.builtInputs + [ nuget-to-json ];
    dontConfigureNuget = true;
    shellHook = ''
      set -ue
      cd pkgs/by-name/wi/wix
      rm -rf tmp && mkdir -p tmp/build tmp/out
      export out=$PWD/tmp/out
      pushd tmp/build
      source ../../../wix/builder.sh || echo builder.sh failed
      popd > /dev/null
      nuget-to-json $NUGET_PACKAGES > deps.json
      echo "Updated deps.json"
      exit 0
    '';
  };
in
  wix // { inherit update-deps; }
