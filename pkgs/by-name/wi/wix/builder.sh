source $stdenv/setup

cp -r --no-preserve=mode $src wix
cd wix
git tag "v$version"
git remote add origin https://github.com/wixtoolset/wix
for patch in $patches; do
  echo applying patch $patch
  patch -p1 -i $patch
done
find -type f -name '*.dll' -o -name '*.cub' -delete
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

# TODO: trim this project file down, remove stuff we aren't using
cat > $wixnative/wixnative.vcxproj <<'EOF'
<Project ToolsVersion="Current" xmlns="http://schemas.microsoft.com/developer/msbuild/2003" DefaultTargets="Build">
  <PropertyGroup Label="Globals">
    <ProjectGuid>{8497EC72-B8D0-4272-A9D0-7E9D871CEFBF}</ProjectGuid>
    <ProjectName>wixnative</ProjectName>
  </PropertyGroup>
  <PropertyGroup>
    <Configuration Condition="'$(Configuration)' == ''">Release</Configuration>
    <Platform Condition="'$(Platform)' == ''">AnyCPU</Platform>
  </PropertyGroup>
  <!--
    Export the path to your prebuilt native EXE.
    Set this from the command line in Nix, e.g.:
      msbuild ... /p:WixNativeExePath=/nix/store/.../wixnative.exe
    Or hardcode a repo-relative path if you prefer.
  -->
  <PropertyGroup>
    <WixNativeExePath Condition="'$(WixNativeExePath)' == ''">$(MSBuildThisFileDirectory)/../../../../build_wixnative/wixnative.exe</WixNativeExePath>
    <!-- Optional: a stable “output” folder for generated props -->
    <WixNativePropsDir Condition="'$(WixNativePropsDir)' == ''">$(IntermediateOutputPath)</WixNativePropsDir>
    <WixNativePropsPath Condition="'$(WixNativePropsPath)' == ''">$(WixNativePropsDir)wixnative.generated.props</WixNativePropsPath>
  </PropertyGroup>
  <!-- Make sure IntermediateOutputPath exists even if nobody set it -->
  <PropertyGroup>
    <BaseIntermediateOutputPath Condition="'$(BaseIntermediateOutputPath)' == ''">obj/</BaseIntermediateOutputPath>
    <IntermediateOutputPath Condition="'$(IntermediateOutputPath)' == ''">$(BaseIntermediateOutputPath)wixnative/</IntermediateOutputPath>
  </PropertyGroup>
  <!-- No-op build -->
  <Target Name="Build" />
  <!-- Optional: write a props file other projects can Import -->
  <Target Name="WriteProps">
    <MakeDir Directories="$(WixNativePropsDir)" />
    <WriteLinesToFile
      File="$(WixNativePropsPath)"
      Overwrite="true"
      Lines="
&lt;Project xmlns=&quot;http://schemas.microsoft.com/developer/msbuild/2003&quot;&gt;
  &lt;PropertyGroup&gt;
    &lt;WixNativeExePath&gt;$(WixNativeExePath)&lt;/WixNativeExePath&gt;
  &lt;/PropertyGroup&gt;
&lt;/Project&gt;"
    />
  </Target>
  <!-- No-op clean/rebuild -->
  <Target Name="Clean" />
  <Target Name="Rebuild" />
</Project>
EOF

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

FLAGS="
--configuration Release
-p:TargetFrameworks=netstandard2.0 -p:TargetFramework=netstandard2.0 -p:GenerateDocumentationFile=false -p:ContinuousIntegrationBuild=true -p:Deterministic=true -p:NuGetAudit=false -clp:NoSummary
"

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

echo "==== Publishing wix.csproj ===="
dotnet publish wix/src/wix/wix/wix.csproj $FLAGS \
  --output $out/lib/wix \
  --no-restore --no-build \
  --no-self-contained -p:PublishTrimmed=false -p:UseAppHost=true

cp wix/LICENSE.TXT $out/
