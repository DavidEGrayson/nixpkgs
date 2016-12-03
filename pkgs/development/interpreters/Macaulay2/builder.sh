source $stdenv/setup

export NIX_CFLAGS_COMPILE="$NIX_CFLAGS_COMPILE -isystem $libxml2_dev/include/libxml2"

nix-store --restore src < $src
cd src/M2

make

./configure --prefix=$out

make check

make install
