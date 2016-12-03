source $stdenv/setup

export NIX_CFLAGS_COMPILE="$NIX_CFLAGS_COMPILE -isystem $libxml2_dev/include/libxml2"

cp --no-preserve=all -r $src/M2 .
cd M2

make

./configure --prefix=$out

make check

make install
