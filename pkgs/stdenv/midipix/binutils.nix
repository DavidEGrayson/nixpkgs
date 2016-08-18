# This function produces a derivation for a binutils package targeting
# the midipix system.
#
# Once the upstream binutils adds support for midipix, we can delete
# this file and just use the other binutils.nix.  Until then, it is
# too much work to keep our Midipix-specific patches up-to-date with
# the latest version of binutils.

{ stdenv, fetchurl, zlib, crossSystem ? null }:

let basename = "binutils-2.24.51";
    noSysDirs = true;
in

with { inherit (stdenv.lib) optional optionals optionalString; };

stdenv.mkDerivation rec {
  name = basename + optionalString (crossSystem != null) "-${crossSystem.config}";

  src = fetchurl {
    url = "ftp://sourceware.org/pub/binutils/snapshots/${basename}.tar.bz2";
    sha256 = "1n4zjibdvqwz63kkzkjdqdp1nh993pn0lml6yyr19yx4gb44dhrr";
  };

  patches = [
    # Turn on --enable-new-dtags by default to make the linker set
    # RUNPATH instead of RPATH on binaries.  This is important because
    # RUNPATH can be overriden using LD_LIBRARY_PATH at runtime.
    ./new-dtags.patch

    # Since binutils 2.22, DT_NEEDED flags aren't copied for dynamic outputs.
    # That requires upstream changes for things to work. So we can patch it to
    # get the old behaviour by now.
    ./dtneeded.patch

    # Make binutils output deterministic by default.
    ./deterministic.patch

    # Always add PaX flags section to ELF files.
    # This is needed, for instance, so that running "ldd" on a binary that is
    # PaX-marked to disable mprotect doesn't fail with permission denied.
    ./pt-pax-flags.patch
  ];

  outputs = (optional (crossSystem == null) "dev") ++ [ "out" "info" ];

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
    for i in binutils/Makefile.in gas/Makefile.in ld/Makefile.in gold/Makefile.in; do
        sed -i "$i" -e 's|ln |ln -s |'
    done
  '';

  # As binutils takes part in the stdenv building, we don't want references
  # to the bootstrap-tools libgcc (as uses to happen on arm/mips)
  NIX_CFLAGS_COMPILE = if stdenv.isDarwin
    then "-Wno-string-plus-int -Wno-deprecated-declarations"
    else "-static-libgcc";

  configureFlags =
    [ "--enable-shared" "--enable-deterministic-archives" "--disable-werror" ]
    ++ optional (stdenv.system == "mips64el-linux") "--enable-fix-loongson2f-nop"
    ++ optional (cross != null) "--target=${cross.config}"
    ++ optionals gold [ "--enable-gold" "--enable-plugins" ]
    ++ optional (stdenv.system == "i686-linux") "--enable-targets=x86_64-linux-gnu";

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
