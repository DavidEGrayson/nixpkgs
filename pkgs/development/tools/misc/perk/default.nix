{ stdenv, fetchgit }:

stdenv.mkDerivation rec {
  name = "perk-${version}";
  version = "2016-06-25";

  meta = {
    description = "PE Resource Kit";
    homepage = "http://git.midipix.org/cgit.cgi/perk";
    license = stdenv.lib.licenses.mit;
    platforms = stdenv.lib.platforms.all;
    maintainers = [ stdenv.lib.maintainers.davidegrayson ];
  };

  src = fetchgit {
    url = "git://midipix.org/perk";
    rev = "6d7c60d7a9a1592d5cbe6bfd7817fdd3a302142c";
    sha256 = "05mj7s6qkbak1srfcji27x2ayvklml4sd50ya80rmk3hwws0pgr7";
  };

  # perk uses _BSD_SOURCE by default, which makes glibc emit a warning:
  # "_BSD_SOURCE and _SVID_SOURCE are deprecated, use _DEFAULT_SOURCE".
  # Adding _DEFAULT_SOURCE is enough to remove the warning even though
  # perk keeps using _BSD_SOURCE anyway.
  CFLAGS = "-D_DEFAULT_SOURCE";

  postInstall = ''cp $src/COPYING.PERK $out'';
}
