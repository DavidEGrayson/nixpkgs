{ lib, stdenv, fetchgit, buildDotnetModule, dotnetCorePackages, git }:
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
buildDotnetModule rec {
  inherit pname version src;

  nativeBuildInputs = [ git ];

  dotnet-sdk = dotnetCorePackages.sdk_8_0;
  dotnet-runtime = dotnet-sdk.runtime;

  nugetDeps = ./deps.json;
  projectFile = "src/api/wix/WixToolset.Data/WixToolset.Data.csproj";  # tmphax

  dotnetFlags = [
    "/p:TargetFramework=netstandard2.0"
  ];

  dotnetRestoreFlags = [
    "/p:NoWarn=NU1604"
  ];

  preConfigure = ''
    echo "Building SomeVerInit"
    dotnet build ./src/internal/SetBuildNumber/SomeVerInit.verproj \
      --configuration "$dotnetBuildType"
  '';

  meta = {
    description = "The most powerful set of tools available to create your Windows installation experience.";
    homepage = "https://www.firegiant.com/wixtoolset/";
    license = lib.licenses.msrl;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "wix";
  };
}
