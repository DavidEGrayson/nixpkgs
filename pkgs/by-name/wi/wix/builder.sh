source $stdenv/setup

cp -r --no-preserve=mode $src wix
cd wix
git tag "v$version"
git remote add origin https://github.com/wixtoolset/wix
for patch in $patches; do
  echo applying patch $patch
  patch -p1 -i $patch
done
cd ..

echo "==== Building dutil ===="
dutil=$PWD/wix/src/libs/dutil/WixToolset.DUtil
mkdir build_dutil
cd build_dutil
x86_64-w64-mingw32-g++ -I $dutil/inc/ $dutil/acl2util.cpp -o acl2util.o
ar rcs dutil.a *.o
cd ..
echo "==== Done building dutil ===="

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

build_artifact() {
  local proj=$1
  echo "==== Building $(basename $proj) ===="
  dotnet build $proj $FLAGS
  dotnet pack $proj $FLAGS --output "$artifacts"
  echo "==== Done building $(basename $proj) ===="
  echo
}

echo "building SomeVerInit"
dotnet build wix/src/internal/SetBuildNumber/SomeVerInit.verproj $FLAGS

build_artifact wix/src/api/wix/WixToolset.Data/WixToolset.Data.csproj
build_artifact wix/src/dtf/WixToolset.Dtf.Resources/WixToolset.Dtf.Resources.csproj
build_artifact wix/src/api/wix/WixToolset.Extensibility/WixToolset.Extensibility.csproj
build_artifact wix/src/libs/WixToolset.Versioning/WixToolset.Versioning.csproj

dotnet build wix/src/wix/wix/wix.csproj $FLAGS

#dotnet publish wix/src/wix/wix/wix.csproj $FLAGS \
#  --output $out/lib/wix \
#  --no-restore --no-build --runtime linux-x64 \
#  --no-self-contained -p:PublishTrimmed=false -p:UseAppHost=true

cp wix/LICENSE.TXT $out/
