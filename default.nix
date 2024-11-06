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
    if need-all || need-coverage || need-catch3
    then catch2_3
    else [];
  add-clang-build-analyzer = need-all: need-clang-buil-analyzer:
    if need-all || need-clang-build-analyzer
    then callPackage ./nix/clang-build-analyzer.nix { inherit clang; }
    else [];
  add-clang-tools = need-all: need-clang-tools:
    if need-all || need-clang-tools
    then clang-tools
    else [];
  add-codechecker = need-all: need-codechecker:
    if need-all || need-codechecker
    then callPackage ./nix/codechecker.nix { inherit clang; }
    else [];
  add-coverxygen = need-all: need-doxygen:
    if need-all || need-doxygen
    then callPackage ./nix/coverxygen.nix { doxygen = (add-doxygen need-all need-doxygen); }
    else [];
  add-cppcheck = need-all: need-cppcheck:
    if need-all || need-cppcheck
    then cppcheck
    else [];
  add-doxygen = need-all: need-doxygen:
    if need-all || need-doxygen
    then callPackage ./nix/doxygen.nix { inherit llvmPackages; }
    else [];
  add-gcovr = need-all: need-coverage:
    if need-all || need-coverage
    then gcovr
    else [];
  add-include-what-you-use = need-all: need-include-what-you-use:
    if need-all || need-include-what-you-use
    then include-what-you-use
    else [];
  add-lcov = need-all: need-coverage:
    if need-all || need-coverage
    then lcov
    else [];
  add-lizard = need-all: need-lizard:
    if need-all || need-lizard
    then callPackage ./nix/lizard.nix {}
    else [];
  add-llvm = need-all: need-coverage:
    if need-all || need-coverage
    then llvmPackages.llvm
    else [];
  add-m-css = need-all: need-doxygen: need-m-css:
    if need-all || (need-doxygen && need-m-css)
    then callPackage ./nix/m-css.nix { doxygen = (add-doxygen need-all need-doxygen); }
    else [];
  add-sonar-scanner-cli = need-all: need-sonar:
    if need-all || need-sonar
    then sonar-scanner-cli
    else [];
  add-uncrustify = need-all: need-uncrustify:
    if need-all || need-uncrustify
    then callPackage ./nix/uncrustify.nix {}
    else [];

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
