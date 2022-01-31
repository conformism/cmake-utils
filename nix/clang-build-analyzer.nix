{ stdenv
, lib
, fetchFromGitHub
, cmake
, llvmPackages_13
}:

stdenv.mkDerivation {
  name = "clang-build-analyzer";

  src = fetchFromGitHub {
    owner = "aras-p";
    repo = "ClangBuildAnalyzer";
    rev = "5d40542";
    sha256 = "sha256-ZaSj4HD6k4NmUtXkzRdmjbSJmwd2vVXcaCXEyPrWRRo=";
  };

  nativeBuildInputs = [ cmake ];
  propagatedBuildInputs = [ llvmPackages_13.clang ];

  meta = {
    homepage = "https://github.com/aras-p/ClangBuildAnalyzer";
    description = "Clang build analysis tool using -ftime-trace";
    license = lib.licenses.unlicense;
    maintainers = [];
  };
}
