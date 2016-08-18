# Hint: run
#  nix-build pkgs/top-level/midipix.nix -A binutilsCross

import ./. {
  system = builtins.currentSystem;
  crossSystem = {
    config = "x86_64-nt64-midipix";
    libc = "musl";
  };
}
