{ stdenv, fetchgit }:

stdenv.mkDerivation {
  name = "lazy";

  meta = {
    description = "A shell-based build system for the digital humanities";
    homepage = "http://git.midipix.org/cgit.cgi/lazy";
    license = stdenv.lib.licenses.free;
    platforms = stdenv.lib.platforms.all;
    maintainers = [ stdenv.lib.maintainers.davidegrayson ];
    updateWalker = true;
    fullRegenerate = true;
    version = "??";
  };

  src = fetchgit {
    url = "git://midipix.org/lazy";
    rev = "04984a9f033a1da05d7ac648a0ed3686dee24d0b";
    sha256 = "0jbk0dkm9z7fkqpy1by4giaax9a1r9xkbmj982xhv36w64cxvy6p";
  };

  dontBuild = true;

  installPhase = ''
    cd "$src"
    mkdir -p "$out/bin"
    cp -r lazy arch toolchain triple "$out/bin"
    cp COPYING.MIDIPIX "$out"
  '';
}

# Tip: run this to update:
#   sh pkgs/build-support/upstream-updater/update-walker.sh pkgs/development/tools/build-managers/lazy/default.nix
