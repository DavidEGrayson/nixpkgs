source $stdenv/setup

git clone https://github.com/Macaulay2/M2
cd M2
git checkout -q $commit
git submodule init
git submodule update
find -type d -name .git -prune -exec rm -rf {} \;

cd ..
mv M2 $out
