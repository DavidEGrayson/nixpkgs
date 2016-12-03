source $stdenv/setup

export NIX_CFLAGS_COMPILE="$NIX_CFLAGS_COMPILE -isystem $libxml2_dev/include/libxml2"

tar -xf $src
cd M2-$commit/M2

make

./configure --prefix=$out

make check

make install
