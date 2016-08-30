# This file helps us test some assertions about the treatment of the
# crossSystem top-level argument.

# Assert that the presence of a crossSystem argument does not affect
# native packages.  For now we just test a few packages that had
# issues in the past, but maybe later we can test all of them.
rec {
  topLevel = import ../pkgs/top-level;

  pkgs = topLevel {
    system = builtins.currentSystem;
    crossSystem = null;
  };

  pkgsWithCross = topLevel {
    system = builtins.currentSystem;
    crossSystem = {
      config = "foosys";
      libc = "foolibc";
    };
  };

  sameLibiconv = pkgs.libiconv == pkgsWithCross.libiconv;
  sameGcc5 = pkgs.gcc5 == pkgsWithCross.gcc5;

  testPass = sameLibiconv && sameGcc5;
}
