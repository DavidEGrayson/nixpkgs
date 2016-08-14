{ stdenv, fetchurl }:

stdenv.mkDerivation rec {
  name = "slibtool-${version}";
  version = "0.5.7";

  meta = {
    description = "A skinny libtool implementation, written in C.";
    homepage = "http://git.midipix.org/cgit.cgi/slibtool";
    license = stdenv.lib.licenses.mit;
    platforms = stdenv.lib.platforms.all;
    maintainers = [ stdenv.lib.maintainers.davidegrayson ];
  };

  src = fetchurl {
    url = "http://midipix.org/dl/slibtool/slibtool-${version}.tar.xz";
    sha256 = "0biiic4nrliqkwp1l65dnp04gxp719afp2gxh2d95ix4qj8qp7f3";
  };

  postInstall = ''cp COPYING.SLIBTOOL $out'';
}
