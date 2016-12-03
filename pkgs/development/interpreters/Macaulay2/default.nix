{
  autoconf,
  automake,
  bison,
  boehmgc,
  boost,
  cddlib,
  emacs,
  fetchurl,
  flex,
  flint,
  gdbm,
  gfan,
  gfortran,
  givaro,
  glpk,
  gmp,      # Note: Macaulay 2 called for the gmp3 Debian package
  gtest,
  liblapack,
  libmpc,
  libtool,
  libxml2,
  lzma,
  mpfr,
  nauty,
  ncurses,  # Note: Macaulay 2 called for ncurses5
  ntl,
  pari,
  pkgconfig,
  readline,
  stdenv,
  subversion,
  texinfo,
  unzip,
  zlib
  # Note: Macaulay 2 docs also listed these Ubuntu packages:
  #   pinentry-curses, xbase-clients, openssh-server.
}:

stdenv.mkDerivation rec {
  name = "macaulay2-1.9.2";

  commit = "634723eb418b6329e56a2c7037a7fc38c2d48a59";

  src = fetchurl {
    url = "https://github.com/Macaulay2/M2/archive/${commit}.tar.gz";
    sha256 = "0qs6253sxf88023zr54228ykp77rbd0sg1kc3mmk0bv9qip3gd2x";
  };

  buildInputs = [
    autoconf automake bison boehmgc boost cddlib emacs flex flint gdbm gfan
    gfortran givaro glpk gmp gtest liblapack libmpc libtool libxml2 lzma mpfr
    nauty ncurses ntl pari pkgconfig readline subversion texinfo unzip zlib
  ];

  libxml2_dev = libxml2.dev;  # TODO: something nicer

  builder = ./builder.sh;

  FC = "gfortran";

  doCheck = true;

  meta = {
    description = "A software system for research in algebraic geometry";
    longDescription = ''
      Macaulay2 is a software system devoted to supporting research in algebraic
      geometry and commutative algebra, whose creation has been funded by the
      National Science Foundation since 1992.
    '';
    homepage = http://www.math.illinois.edu/Macaulay2/;
    license = stdenv.lib.licenses.gpl3;
    maintainers = [];
    platforms = stdenv.lib.platforms.all;
  };
}
