source $stdenv/setup

git clone https://github.com/Macaulay2/M2
cd M2
git checkout -q $commit
git submodule update --init M2/submodules/{memtailor,mathic,mathicgb}
find -type d -name .git -prune -exec rm -rf {} \;

nix-store --dump . > $out
