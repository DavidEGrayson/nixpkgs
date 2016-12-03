{
  autoconf,
  automake,
  bison,
  boehmgc,
  boost,
  cacert,
  cddlib,
  emacs,
  fetchurl,
  flex,
  flint,
  gdbm,
  gfan,
  gfortran,
  git,
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
  nix,
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
  name = "macaulay2-${version}";
  version = "1.9.2";
  commit = "634723eb418b6329e56a2c7037a7fc38c2d48a59";

  src = stdenv.mkDerivation rec {
    name = "macaulay2-full-source-${version}.nar";
    buildInputs = [ git nix ];
    SSL_CERT_FILE = "${cacert}/etc/ssl/certs/ca-bundle.crt";
    inherit commit;
    builder = ./downloader.sh;
    outputHashAlgo = "sha256";
    outputHashMode = "flat";
    outputHash = "0jwwijg5k0vnrp9mlf555n2bijpggqljcax9kvy79k46fgj6v82q";
  };

  buildInputs = [
    autoconf automake bison boehmgc boost cddlib emacs flex flint gdbm gfan
    gfortran givaro glpk gmp gtest liblapack libmpc libtool libxml2 lzma mpfr
    nauty ncurses nix ntl pari pkgconfig readline subversion texinfo unzip zlib
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
