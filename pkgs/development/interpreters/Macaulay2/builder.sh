source $stdenv/setup

export NIX_CFLAGS_COMPILE="$NIX_CFLAGS_COMPILE -isystem $libxml2_dev/include/libxml2"

nix-store --restore src < $src
cd src/M2

for x in $othersrcs; do cp "$x" "BUILD/tarfiles/$(basename $x | sed 's/\w\{32\}-//')"; done

make

./configure --prefix=$out

make

make check

make install
