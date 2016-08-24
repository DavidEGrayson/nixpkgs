# Given a stdenv that runs on the build system and produces binaries
# that run on the build system, produces a cross-compiling stdenv that
# runs on the build system and produces binaries for the Midipix
# system specified by crossSystem.

{ defaultStdenv, crossSystem, zlib, fetchurl }:

assert crossSystem.config == "x86_64-nt64-midipix";

rec {

  binutils = import ./binutils.nix {
    stdenv = defaultStdenv;
    inherit crossSystem zlib fetchurl;
  };

  gccStage1 = import ./gcc.nix {
    stdenv = defaultStdenv;
    inherit crossSystem zlib fetchurl binutils;
  };
  mkDerivation = "wtf";
}
