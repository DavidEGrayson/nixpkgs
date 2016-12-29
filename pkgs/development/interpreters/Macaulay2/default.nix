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
  libatomic_ops,
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
  perl,
  pkgconfig,
  readline,
  stdenv,
  subversion,
  texinfo,
  unzip,
  zlib,
  # Note: Macaulay 2 docs also listed these Ubuntu packages:
  #   pinentry-curses, xbase-clients, openssh-server.

  wget
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
    outputHash = "1gzg7f03jbv8amgz3dg0k9zykb8mvxhv0r5sbp2g53rj576wskif";
  };

  othersrcs = [
    (fetchurl {
      url = "http://www.math.uiuc.edu/Macaulay2/Downloads/OtherSourceCode/4ti2-1.6.7.tar.gz";
      sha256 = "1frix3rnm9ffr93alqzw4cavxbfpf524l8rfbmcpyhwd3n1km0yl";
    })
    (fetchurl {
      url = "http://www.math.uiuc.edu/Macaulay2/Downloads/OtherSourceCode/factory.4.0.1-gftables.tar.gz";
      sha256 = "1ggf237bskkqr91nmsm0mbhb0b59pc2b1h52vixw9cf2n775ilcw";
    })
    (fetchurl {
      url = "http://www.math.uiuc.edu/Macaulay2/Downloads/OtherSourceCode/factory-4.0.2.tar.gz";
      sha256 = "1wg9s23vazbs159g4540fq5jhaw1a8q91l555bahnd4x5nq7i42f";
    })
    (fetchurl {
      url = "http://www.math.uiuc.edu/Macaulay2/Downloads/OtherSourceCode/fflas-ffpack-1.6.0.tar.gz";
      sha256 = "02fr675278c65hfiy1chb903j4ix9i8yni1xc2g5nmsjcaf9vra9";
    })
    (fetchurl {
      url = "http://www.math.uiuc.edu/Macaulay2/Downloads/OtherSourceCode/flint-2.5.2.tar.gz";
      sha256 = "11syazv1a8rrnac3wj3hnyhhflpqcmq02q8pqk2m6g2k6h0gxwfb";
    })
    (fetchurl {
      url = "http://www.math.uiuc.edu/Macaulay2/Downloads/OtherSourceCode/frobby_v0.9.0.tar.gz";
      sha256 = "1pv201j613d31bhk0wklj2k0klsw1sp4g5z7yj39r16wws1j62dg";
    })
    (fetchurl {
      url = "http://www.math.uiuc.edu/Macaulay2/Downloads/OtherSourceCode/gfan0.5.tar.gz";
      sha256 = "0adk9pia683wf6kn6h1i02b3801jz8zn67yf39pl57md7bqbrsma";
    })
    (fetchurl {
      url = "http://www.math.uiuc.edu/Macaulay2/Downloads/OtherSourceCode/gtest-1.7.0.tar.gz";
      sha256 = "1i4vdhgmxa831s71g2qbgqlpaf8fszghpzb2njpf11kwwkp61y60";
    })
    (fetchurl {
      url = "http://www.math.uiuc.edu/Macaulay2/Downloads/OtherSourceCode/lapack-3.6.0.tgz";
      sha256 = "1hzz6fiam6c1gm2i7ixxdjkxqs37c5bh0mxxgcvlxqcgj4n0i859";
    })
    (fetchurl {
      url = "http://www.math.uiuc.edu/Macaulay2/Downloads/OtherSourceCode/mpfr-3.1.4.tar.xz";
      sha256 = "1x8pcnpn1vxfzfsr0js07rwhwyq27fmdzcfjpzi5773ldnqi653n";
    })
    (fetchurl {
      url = "http://www.math.uiuc.edu/Macaulay2/Downloads/OtherSourceCode/mpir-2.7.2.tar.bz2";
      sha256 = "1v25dx7cah2vxwzgq78hpzqkryrfxhwx3mcj3jjq3xxljlsw7m57";
    })
    (fetchurl {
      url = "http://www.math.uiuc.edu/Macaulay2/Downloads/OtherSourceCode/nauty26r3.tar.gz";
      sha256 = "0qac5kmdr4ddxna78j4an48i7hyam0dg2khh8ib3ip8yrqh1aci7";
    })
    (fetchurl {
      url = "http://www.math.uiuc.edu/Macaulay2/Downloads/OtherSourceCode/Normaliz3.1.1Source.zip";
      sha256 = "0dfxzd5zy3pq5kiimc1520y72gj49jlpn4gqckl81gpqw5b9fp16";
    })
    (fetchurl {
      url = "http://www.math.uiuc.edu/Macaulay2/Downloads/OtherSourceCode/ntl-9.7.0.tar.gz";
      sha256 = "115frp5flyvw9wghz4zph1b3llmr5nbxk1skgsggckr81fh3gmxq";
    })
    (fetchurl {
      url = "http://www.math.uiuc.edu/Macaulay2/Downloads/OtherSourceCode/pari-2.7.5.tar.gz";
      sha256 = "0c8l83a0gjq73r9hndsrzkypwxvnnm4pxkkzbg6jm95m80nzwh11";
    })
  ];

  buildInputs = [
    autoconf automake bison boehmgc boost cddlib emacs flex flint gdbm gfan
    gfortran givaro glpk gmp gtest libatomic_ops liblapack libmpc libtool libxml2 lzma mpfr
    nauty ncurses nix ntl pari perl pkgconfig readline subversion texinfo unzip wget zlib
  ];

  # inherit mpir27;

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
