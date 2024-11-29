{ lib
, callPackage
, stdenv
, stdenvNoCC
, cairosvg
, catch2_3
, clang
, clang-build-analyzer
, clang-tools
, codechecker
, coverxygen
, cppcheck
, doxygen
, editorconfig-checker
, gcovr
, git
, imagemagick
, include-what-you-use
, lcov
, lizard
, llvmPackages
, m-css
, sonar-scanner-cli
, uncrustify
, with-catch3 ? false
, with-clang-build-analyzer ? false
, with-clang-tools ? false
, with-codechecker ? false
, with-coverage ? false
, with-cppcheck ? false
, with-doxygen ? false
, with-icon ? false
, with-include-what-you-use ? false
, with-lizard ? false
, with-m-css ? false
, with-sonar ? false
, with-uncrustify ? false
}:

 stdenvNoCC.mkDerivation {
  name = "cmake-utils";
  version = "0.0.0";

  src = ./.;

  buildInputs = [
    git
    clang
    editorconfig-checker
  ] ++ lib.optionals with-coverage [
    gcovr
    lcov
    llvmPackages.llvm
  ] ++ lib.optionals (with-coverage || with-catch3) [
    catch2_3
  ] ++ lib.optionals with-clang-build-analyzer [
    clang-build-analyzer
    clang-tools
  ] ++ lib.optionals with-codechecker [
    codechecker
  ] ++ lib.optionals with-cppcheck [
    cppcheck
  ] ++ lib.optionals with-doxygen [
    coverxygen
    doxygen
  ] ++ lib.optionals (with-doxygen && with-m-css) [
    m-css
  ] ++ lib.optionals with-icon [
    cairosvg
    imagemagick
  ] ++ lib.optionals with-include-what-you-use [
    include-what-you-use
  ] ++ lib.optionals with-lizard [
    lizard
  ] ++ lib.optionals with-sonar [
    sonar-scanner-cli
  ] ++ lib.optionals with-uncrustify [
    uncrustify
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
