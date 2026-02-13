{ lib, stdenv, fetchgit, dotnetCorePackages, git }:
let
  pname = "wix";
  version = "6.0.2";
  src = fetchgit {
    url = "https://github.com/wixtoolset/wix";
    rev = "v${version}";
    hash = "sha256-6ii0VdSGuBVS4GL0W9I/sj694a0+Dg0xTKLxEQDwmGo=";
    leaveDotGit = true;
  };
in
stdenv.mkDerivation rec {
  inherit pname version src;

  buildInputs = map dotnetCorePackages.fetchNupkg (lib.importJSON ./deps.json);

  nativeBuildInputs = [ git dotnetCorePackages.sdk_8_0 ];

  builder = ./builder.sh;

  meta = {
    description = "The most powerful set of tools available to create your Windows installation experience.";
    homepage = "https://www.firegiant.com/wixtoolset/";
    license = lib.licenses.msrl;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "wix";
  };
}
