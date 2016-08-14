{ stdenv, fetchgit }:

stdenv.mkDerivation rec {
  name = "perk-${version}";
  version = "2016-08-14";

  meta = {
    description = "PE Resource Kit";
    homepage = "http://git.midipix.org/cgit.cgi/perk";
    license = stdenv.lib.licenses.mit;
    platforms = stdenv.lib.platforms.all;
    maintainers = [ stdenv.lib.maintainers.davidegrayson ];
  };

  src = fetchgit {
    url = "git://midipix.org/perk";
    rev = "85d6bd6b49b6481f44cdbf568f398df15238468f";
    sha256 = "0s7q895bd19mb4gdpv7yj1pf9zd3xn7ii0qilz9khigb2bgaymgn";
  };

  postInstall = ''cp $src/COPYING.PERK $out'';
}
