source $stdenv/setup

cp -r --no-preserve=mode $src/src .

echo "building SomeVerInit"
dotnet msbuild src/internal/SetBuildNumber/SomeVerInit.verproj -nologo

dotnet msbuild src/api/wix/WixToolset.Data/WixToolset.Data.csproj

csc -target:library -out:Converters.dll src/wix/WixToolset.Converters/*.cs

mcs src/wix/wix/Program.cs -out:wix.exe


