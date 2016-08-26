# Hint: run
#  nix-build pkgs/top-level/midipix.nix -A binutilsCross

# TODO: what is wrong with this file?
#
# Why do these two commands give different results?
# (e.g. different derivations, or the first one giving an error)
#
#  nix-instantiate pkgs/top-level/midipix.nix -A gcc
#  nix-instantiate pkgs/top-level/impure.nix -A gcc

import ./. {
  system = builtins.currentSystem;
  crossSystem = {
    config = "x86_64-nt64-midipix";
    libc = "musl";
  };
}
