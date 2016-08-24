# This function produces a derivation for a binutils package targeting
# the midipix system.
#
# This function was originally made by copying
# pkgs/development/tools/misc/binutils/default.nix and then making a
# few changes to make it support midipix.  Some features that
# obviously were not needed for midipix were removed.
#
# Once the upstream binutils adds support for midipix, we can delete
# this file and just use the other binutils.nix.  Until then, it is
# too much work to keep our Midipix-specific patches up-to-date with
# the latest version of binutils.

{ stdenv, fetchurl, zlib, bison, crossSystem ? null }:

let basename = "binutils-2.24.51";
    noSysDirs = true;
    cross = crossSystem;
in

with { inherit (stdenv.lib) optional optionals optionalString; };

stdenv.mkDerivation rec {
  name = basename + optionalString (cross != null) "-${cross.config}";

  src = fetchurl {
    url = "ftp://sourceware.org/pub/binutils/snapshots/${basename}.tar.bz2";
    sha256 = "250d3b2925c6b211fb16173b0b25bc091c58829fbcad3eb849645e0af52cf7fa";
  };

  patches = [
    # Turn on --enable-new-dtags by default to make the linker set
    # RUNPATH instead of RPATH on binaries.  This is important because
    # RUNPATH can be overriden using LD_LIBRARY_PATH at runtime.
    # This patch was copied from pkgs/development/tools/misc/binutils.
    ./new-dtags.patch

    # Since binutils 2.22, DT_NEEDED flags aren't copied for dynamic outputs.
    # That requires upstream changes for things to work. So we can patch it to
    # get the old behaviour by now.
    # This patch was copied from pkgs/development/tools/misc/binutils.
    ./dtneeded.patch

    # Make binutils output deterministic by default.
    # This patch was copied from pkgs/development/tools/misc/binutils.
    ./deterministic.patch

    # This patch was downloaded from
    # http://git.midipix.org/cgit.cgi/ports/portage/plain/binutils-2.24.51.midipix.patch
    ./binutils-2.24.51.midipix.patch
  ];

  outputs = (optional (cross == null) "dev") ++ [ "out" "info" ];

  nativeBuildInputs = [ bison ];
  buildInputs = [ zlib ];

  inherit noSysDirs;

  preConfigure = ''
    # Clear the default library search path.
    if test "$noSysDirs" = "1"; then
        echo 'NATIVE_LIB_DIRS=' >> ld/configure.tgt
    fi

    # Use symlinks instead of hard links to save space ("strip" in the
    # fixup phase strips each hard link separately).
    for i in binutils/Makefile.in gas/Makefile.in ld/Makefile.in; do
        sed -i "$i" -e 's|ln |ln -s |'
    done
  '';

  # As binutils takes part in the stdenv building, we don't want references
  # to the bootstrap-tools libgcc (as used to happen on arm/mips)
  NIX_CFLAGS_COMPILE = "-static-libgcc";

  configureFlags =
    [ "--enable-shared" "--enable-deterministic-archives" "--disable-werror" ]
    ++ optional (cross != null) "--target=${cross.config}";

  enableParallelBuilding = true;

  postFixup = optionalString (cross == null) "ln -s $out/bin $dev/bin"; # tools needed for development

  meta = with stdenv.lib; {
    description = "Tools for manipulating binaries (linker, assembler, etc.)";
    longDescription = ''
      The GNU Binutils are a collection of binary tools.  The main
      ones are `ld' (the GNU linker) and `as' (the GNU assembler).
      They also include the BFD (Binary File Descriptor) library,
      `gprof', `nm', `strip', etc.
    '';
    homepage = http://www.gnu.org/software/binutils/;
    license = licenses.gpl3Plus;
    platforms = platforms.unix;

    /* Give binutils a lower priority than gcc-wrapper to prevent a
       collision due to the ld/as wrappers/symlinks in the latter. */
    priority = "10";
  };
}
