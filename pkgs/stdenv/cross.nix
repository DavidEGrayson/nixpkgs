let
  # Return a modified stdenv that adds a cross compiler to the
  # builds.
  #
  # NOTE: This function is here for now because we will probably be
  # taking info from it and using it in this file.  For now though,
  # it is not yest.
  makeStdenvCross = stdenv: cross: binutilsCross: gccCross: stdenv //
    { mkDerivation = {name ? "", buildInputs ? [], nativeBuildInputs ? [],
            propagatedBuildInputs ? [], propagatedNativeBuildInputs ? [],
            selfNativeBuildInput ? false, ...}@args: let

            # *BuildInputs exists temporarily as another name for
            # *HostInputs.

            # In nixpkgs, sometimes 'null' gets in as a buildInputs element,
            # and we handle that through isAttrs.
            getNativeDrv = drv: drv.nativeDrv or drv;
            getCrossDrv = drv: drv.crossDrv or drv;
            nativeBuildInputsDrvs = map getNativeDrv nativeBuildInputs;
            buildInputsDrvs = map getCrossDrv buildInputs;
            propagatedBuildInputsDrvs = map getCrossDrv propagatedBuildInputs;
            propagatedNativeBuildInputsDrvs = map getNativeDrv propagatedNativeBuildInputs;

            # The base stdenv already knows that nativeBuildInputs and
            # buildInputs should be built with the usual gcc-wrapper
            # And the same for propagatedBuildInputs.
            nativeDrv = stdenv.mkDerivation args;

            # Temporary expression until the cross_renaming, to handle the
            # case of pkgconfig given as buildInput, but to be used as
            # nativeBuildInput.
            hostAsNativeDrv = drv:
                builtins.unsafeDiscardStringContext drv.nativeDrv.drvPath
                == builtins.unsafeDiscardStringContext drv.crossDrv.drvPath;
            buildInputsNotNull = stdenv.lib.filter
                (drv: builtins.isAttrs drv && drv ? nativeDrv) buildInputs;
            nativeInputsFromBuildInputs = stdenv.lib.filter hostAsNativeDrv buildInputsNotNull;

            # We should overwrite the input attributes in crossDrv, to overwrite
            # the defaults for only-native builds in the base stdenv
            crossDrv = if cross == null then nativeDrv else
                stdenv.mkDerivation (args // {
                    name = name + "-" + cross.config;
                    nativeBuildInputs = nativeBuildInputsDrvs
                      ++ nativeInputsFromBuildInputs
                      ++ [ gccCross binutilsCross ]
                      ++ stdenv.lib.optional selfNativeBuildInput nativeDrv
                        # without proper `file` command, libtool sometimes fails
                        # to recognize 64-bit DLLs
                      ++ stdenv.lib.optional (cross.config  == "x86_64-w64-mingw32") pkgs.file
                      ;

                    # Cross-linking dynamic libraries, every buildInput should
                    # be propagated because ld needs the -rpath-link to find
                    # any library needed to link the program dynamically at
                    # loader time. ld(1) explains it.
                    buildInputs = [];
                    propagatedBuildInputs = propagatedBuildInputsDrvs ++ buildInputsDrvs;
                    propagatedNativeBuildInputs = propagatedNativeBuildInputsDrvs;

                    crossConfig = cross.config;
                } // args.crossAttrs or {});
        in nativeDrv // {
          inherit crossDrv nativeDrv;
        };
    } // {
      inherit cross gccCross binutilsCross;
      ccCross = gccCross;
    };

in
  { mkDerivation = throw "cross mkDerivation not defined"; }
