{ stdenv
, lib
, fetchFromGitHub
, cmake
, clang
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
  propagatedBuildInputs = [ clang ];

  meta = {
    homepage = "https://github.com/aras-p/ClangBuildAnalyzer";
    description = "Clang build analysis tool using -ftime-trace";
    license = lib.licenses.unlicense;
    maintainers = [];
  };
}
