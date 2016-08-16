{ stdenv
, cross ? null
, gccCross ? null
, noComplex ? false
}:

stdenv.mkDerivation rec {
  name = "musl-midipix-${version}";
  version = "?";
  # TODO: finish this
}
