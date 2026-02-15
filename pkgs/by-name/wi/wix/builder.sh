source $stdenv/setup

cp -r --no-preserve=mode $src wix

export NUGET_PACKAGES=$PWD/nuget_packages
mkdir $NUGET_PACKAGES

if [ -z "$updateDeps" ]; then
  # Making nuget dependencies from Nix accessible to nuget
  # and prevent attempts to download them from the internet.
  configureNuget  # from dotnet-sdk-setup-hook.sh
fi

# Alternative simpler implementation of configureNuget (TODO: delete)
if [ -z "XX$updateDeps" ]; then
mkdir nuget_source
for input in $buildInputs; do
  if [ -d $input/share/nuget/source ]; then
    for x in $input/share/nuget/source/*/*; do
      name=$(basename "$(dirname "$x")")
      mkdir -p "nuget_source/$name"
      ln -s "$x" "nuget_source/$name/"
    done
  fi
  if [ -d $input/share/nuget/packages ]; then
    for x in $input/share/nuget/packages/*/*; do
      name=$(basename "$(dirname "$x")")
      mkdir -p "nuget_packages/$name"
      ln -s "$x" "nuget_packages/$name/"
    done
  fi
done
rm wix/nuget.config
cat > nuget.config <<END
<?xml version="1.0" encoding="utf-8"?>
<configuration>
  <packageSources>
    <clear/>
    <add key="_nix" value="$PWD/nuget_source"/>
    <add key="build" value="$PWD/artifacts"/>
  </packageSources>
  <config><clear/></config>
  <bindingRedirects><clear/></bindingRedirects>
  <packageRestore><clear/></packageRestore>
  <solution><clear/></solution>
  <auditSources><clear/></auditSources>
  <apikeys><clear/></apikeys>
  <disabledPackageSources><clear/></disabledPackageSources>
  <activePackageSource><clear/></activePackageSource>
  <fallbackPackageFolders><clear/></fallbackPackageFolders>
  <packageSourceMapping>
    <packageSource key="_nix">
      <package pattern="*" />
    </packageSource>
    <packageSource key="build">
      <package pattern="WixToolset.*" />
      <package pattern="WixInternal.*" />
    </packageSource>
  </packageSourceMapping>
  <packageManagement>
    <clear/>
  </packageManagement>
</configuration>
END
fi

FLAGS="--configuration Release -p:GenerateDocumentationFile=false -p:ContinuousIntegrationBuild=true -p:Deterministic=true -p:NuGetAudit=false"

echo "building SomeVerInit"
dotnet build wix/src/internal/SetBuildNumber/SomeVerInit.verproj $FLAGS

echo "building WixToolset.Data"
dotnet build wix/src/api/wix/WixToolset.Data/WixToolset.Data.csproj $FLAGS \
  --runtime linux-x64 \
  -p:TargetFramework=netstandard2.0 \
  --property:NoWarn=NU1604%3BCS1591
echo "done building WixToolset.Data"

dotnet publish wix/src/api/wix/WixToolset.Data/WixToolset.Data.csproj $FLAGS \
  --output $out/lib/wix \
  --no-restore --no-build --runtime linux-x64 -p:TargetFramework=netstandard2.0 \
  --no-self-contained -p:PublishTrimmed=false -p:UseAppHost=true

cp wix/LICENSE.TXT $out/
