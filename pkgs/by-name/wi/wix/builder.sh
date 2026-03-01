source $stdenv/setup

cp -r --no-preserve=mode $src wix
cd wix
git tag "v$version"
git remote add origin https://github.com/wixtoolset/wix
for patch in $patches; do
  echo applying patch $patch
  patch -p1 -i $patch
done
find -type f -name '*.dll' -delete
cd ..

wixnative=$PWD/wix/src/wix/wixnative
dutil=$PWD/wix/src/libs/dutil/WixToolset.DUtil

echo "==== Building dutil ===="
CFLAGS="-I $dutil/inc"
mkdir build_dutil
cd build_dutil
x86_64-w64-mingw32-g++ -x c++-header $CFLAGS \
  $dutil/precomp.h -o $dutil/precomp.h.gch
for cpp in $dutil/*.cpp; do
  base=$(basename $cpp)
  echo "compiling $base"
  x86_64-w64-mingw32-g++ -c $CFLAGS $cpp -o $base.o
done
ar rcs dutil.a *.o
cd ..
echo "==== Done building dutil ===="

echo "==== Building wixnative ===="
mkdir build_wixnative
cd build_wixnative
LDFLAGS="-municode -static"
CFLAGS="-municode -I $dutil/inc"
x86_64-w64-mingw32-g++ -x c++-header $CFLAGS \
  $wixnative/precomp.cpp -o $wixnative/precomp.cpp.gch
rm $wixnative/precomp.cpp
for cpp in $wixnative/*.cpp; do
  base=$(basename $cpp)
  echo "compiling $base"
  x86_64-w64-mingw32-g++ -municode -c $CFLAGS $cpp -o $base.o
done
x86_64-w64-mingw32-g++ $LDFLAGS *.o ../build_dutil/dutil.a \
  -lcrypt32 -lcabinet -lmsi -lwintrust -lversion -o wixnative.exe
x86_64-w64-mingw32-strip wixnative.exe
cd ..
echo "==== Done building wixnative ===="

mkdir $out && cp build_wixnative/wixnative.exe $out/
exit 0  # tmphax


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

echo "==== Building wix.csproj ===="
dotnet build wix/src/wix/wix/wix.csproj $FLAGS

#dotnet publish wix/src/wix/wix/wix.csproj $FLAGS \
#  --output $out/lib/wix \
#  --no-restore --no-build --runtime linux-x64 \
#  --no-self-contained -p:PublishTrimmed=false -p:UseAppHost=true

cp wix/LICENSE.TXT $out/
