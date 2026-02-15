source $stdenv/setup

cp -r --no-preserve=mode $src wix
cd wix
git tag "v$version"
git remote add origin https://github.com/wixtoolset/wix
cd ..

if [ "$dontConfigureNuget" = 1 ]; then
  sed -i 's|build\\artifacts|build/artifacts|g' wix/nuget.config
  artifacts=wix/build/artifacts
  export NUGET_PACKAGES=$PWD/nuget_packages
  mkdir $NUGET_PACKAGES
else
  # Make nuget packages from Nix accessible to nuget
  # and prevent attempts to download them from the internet.
  configureNuget  # from dotnet-sdk-setup-hook.sh
  artifacts=$nugetSource
fi

FLAGS="--configuration Release -p:TargetFrameworks=netstandard2.0 -p:GenerateDocumentationFile=false -p:ContinuousIntegrationBuild=true -p:Deterministic=true -p:NuGetAudit=false -clp:NoSummary"

echo "building SomeVerInit"
dotnet build wix/src/internal/SetBuildNumber/SomeVerInit.verproj $FLAGS

echo "building WixToolset.Data"
dotnet build wix/src/api/wix/WixToolset.Data/WixToolset.Data.csproj $FLAGS \
  --property:NoWarn=NU1604%3BCS1591
echo "packing WixToolSet.Data"
dotnet pack wix/src/api/wix/WixToolset.Data/WixToolset.Data.csproj $FLAGS \
  --output "$artifacts"
echo "done with WixToolset.Data"

dotnet build wix/src/wix/wix/wix.csproj $FLAGS

#dotnet publish wix/src/api/wix/WixToolset.Data/WixToolset.Data.csproj $FLAGS \
#  --output $out/lib/wix \
#  --no-restore --no-build --runtime linux-x64 \
#  --no-self-contained -p:PublishTrimmed=false -p:UseAppHost=true

cp wix/LICENSE.TXT $out/
