{ stdenv
, lib
, fetchFromGitHub
, cmake
, clang
}:

stdenv.mkDerivation rec {
  pname = "clang-build-analyzer";
  version = "1.4.0";

  src = fetchFromGitHub {
    owner = "aras-p";
    repo = "ClangBuildAnalyzer";
    rev = "v${version}";
    sha256 = "sha256-uE7EpPGuecM70vWm1IlG+aBBdvUXroWP03tFHYpQykw=";
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
