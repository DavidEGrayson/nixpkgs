{ system, allPackages, platform, config }:

{
  stdenvCross = {
    isCygwin = false;
    isDarwin = false;
  };
}
