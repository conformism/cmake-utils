{ lib
, callPackage
, stdenv
, stdenvNoCC
, catch2_3
, clang
, clang-tools
, cppcheck
, editorconfig-checker
, gcovr
, git
, include-what-you-use
, lcov
, llvmPackages
, sonar-scanner-cli
, need-all ? false
, need-catch3 ? false
, need-clang-build-analyzer ? false
, need-clang-tools ? false
, need-codechecker ? false
, need-coverage ? false
, need-cppcheck ? false
, need-doxygen ? false
, need-include-what-you-use ? false
, need-lizard ? false
, need-m-css ? false
, need-sonar ? false
, need-uncrustify ? false
}:

let
  add-catch3 = need-all: need-coverage: need-catch3:
    lib.optionals
      (need-all || need-coverage || need-catch3)
      catch2_3;
  add-clang-build-analyzer = need-all: need-clang-buil-analyzer:
    lib.optionals
      (need-all || need-clang-build-analyzer)
      (callPackage ./nix/clang-build-analyzer.nix { inherit clang; });
  add-clang-tools = need-all: need-clang-tools:
    lib.optionals
      (need-all || need-clang-tools)
      clang-tools;
  add-codechecker = need-all: need-codechecker:
    lib.optionals
      (need-all || need-codechecker)
      (callPackage ./nix/codechecker.nix { inherit clang; });
  add-coverxygen = need-all: need-doxygen:
    lib.optionals
      (need-all || need-doxygen)
      (callPackage ./nix/coverxygen.nix { doxygen = (add-doxygen need-all need-doxygen); });
  add-cppcheck = need-all: need-cppcheck:
    lib.optionals
      (need-all || need-cppcheck)
      cppcheck;
  add-doxygen = need-all: need-doxygen:
    lib.optionals
      (need-all || need-doxygen)
      (callPackage ./nix/doxygen.nix { inherit llvmPackages; });
  add-gcovr = need-all: need-coverage:
    lib.optionals
      (need-all || need-coverage)
      gcovr;
  add-include-what-you-use = need-all: need-include-what-you-use:
    lib.optionals
      (need-all || need-include-what-you-use)
      include-what-you-use;
  add-lcov = need-all: need-coverage:
    lib.optionals
      (need-all || need-coverage)
      lcov;
  add-lizard = need-all: need-lizard:
    lib.optionals
      (need-all || need-lizard)
      (callPackage ./nix/lizard.nix {});
  add-llvm = need-all: need-coverage:
    lib.optionals
      (need-all || need-coverage)
      llvmPackages.llvm;
  add-m-css = need-all: need-doxygen: need-m-css:
    lib.optionals
      (need-all || (need-doxygen && need-m-css))
      (callPackage ./nix/m-css.nix { doxygen = (add-doxygen need-all need-doxygen); });
  add-sonar-scanner-cli = need-all: need-sonar:
    lib.optionals
      (need-all || need-sonar)
      sonar-scanner-cli;
  add-uncrustify = need-all: need-uncrustify:
    lib.optionals
      (need-all || need-uncrustify)
      (callPackage ./nix/uncrustify.nix {});

in stdenvNoCC.mkDerivation {
  name = "cmake-utils";
  version = "0.0.0";

  src = ./.;

  buildInputs = [
    git
    clang
    editorconfig-checker
    (add-catch3 need-all need-coverage need-catch3)
    (add-clang-build-analyzer need-all need-clang-build-analyzer)
    (add-codechecker need-all need-codechecker)
    (add-coverxygen need-all need-doxygen)
    (add-cppcheck need-all need-cppcheck)
    (add-gcovr need-all need-coverage)
    (add-include-what-you-use need-all need-include-what-you-use)
    (add-lcov need-all need-coverage)
    (add-lizard need-all need-lizard)
    (add-llvm need-all need-coverage)
    (add-m-css need-all need-doxygen need-m-css)
    (add-sonar-scanner-cli need-all need-sonar)
    (add-uncrustify need-all need-uncrustify)
  ];

  installPhase = ''
    make install PREFIX=$out
  '';

  meta = {
    homepage = "https://github.com/conformism/cmake-utils";
    description = "CMake Utilities";
    license = lib.licenses.gpl3;
    maintainers = [
      {
        email = "thomas.lepoix@protonmail.ch";
        github = "thomaslepoix";
        githubId = 26417323;
        name = "Thomas Lepoix";
      }
    ];
  };
}
