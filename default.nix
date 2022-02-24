{ pkgs ? import <nixpkgs> {}
, lib ? pkgs.lib
, stdenv ? pkgs.stdenv
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

with pkgs;

let
  llvmPackages = llvmPackages_13;
  clang = llvmPackages.clang;
  catch3 = need-all: need-coverage: need-catch3:
    if need-all || need-coverage || need-catch3
    then callPackage ./nix/catch3.nix {}
    else [];
  clang-build-analyzer = need-all: need-clang-buil-analyzer:
    if need-all || need-clang-build-analyzer
    then callPackage ./nix/clang-build-analyzer.nix { inherit clang; }
    else [];
  clang-tools = need-all: need-clang-tools:
    if need-all || need-clang-tools
    then pkgs.clang-tools
    else [];
  codechecker = need-all: need-codechecker:
    if need-all || need-codechecker
    then callPackage ./nix/codechecker.nix { inherit clang; }
    else [];
  coverxygen = need-all: need-doxygen:
    if need-all || need-doxygen
    then callPackage ./nix/coverxygen.nix { doxygen = (doxygen need-all need-doxygen); }
    else [];
  cppcheck = need-all: need-cppcheck:
    if need-all || need-cppcheck
    then pkgs.cppcheck
    else [];
  doxygen = need-all: need-doxygen:
    if need-all || need-doxygen
    then callPackage ./nix/doxygen.nix { inherit llvmPackages; }
    else [];
  gcovr = need-all: need-coverage:
    if need-all || need-coverage
    then pkgs.gcovr
    else [];
  include-what-you-use = need-all: need-include-what-you-use:
    if need-all || need-include-what-you-use
    then pkgs.include-what-you-use
    else [];
  lcov = need-all: need-coverage:
    if need-all || need-coverage
    then pkgs.lcov
    else [];
  lizard = need-all: need-lizard:
    if need-all || need-lizard
    then callPackage ./nix/lizard.nix {}
    else [];
  llvm = need-all: need-coverage:
    if need-all || need-coverage
    then llvmPackages.llvm
    else [];
  m-css = need-all: need-doxygen: need-m-css:
    if need-all || (need-doxygen && need-m-css)
    then callPackage ./nix/m-css.nix { doxygen = (doxygen need-all need-doxygen); }
    else [];
  sonar-scanner-cli = need-all: need-sonar:
    if need-all || need-sonar
    then pkgs.sonar-scanner-cli
    else [];
  uncrustify = need-all: need-uncrustify:
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
    (catch3 need-all need-coverage need-catch3)
    (clang-build-analyzer need-all need-clang-build-analyzer)
    (codechecker need-all need-codechecker)
    (coverxygen need-all need-doxygen)
    (cppcheck need-all need-cppcheck)
    (gcovr need-all need-coverage)
    (include-what-you-use need-all need-include-what-you-use)
    (lcov need-all need-coverage)
    (lizard need-all need-lizard)
    (llvm need-all need-coverage)
    (m-css need-all need-doxygen need-m-css)
    (sonar-scanner-cli need-all need-sonar)
    (uncrustify need-all need-uncrustify)
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
