{ catch2
, fetchFromGitHub
}:

catch2.overrideAttrs (old: rec {
  version = "3.0.0-preview4";
  src = fetchFromGitHub {
    owner = "catchorg";
    repo = "Catch2";
    rev = "v${version}";
    sha256="sha256-nLJTe9qAIy+IZpb03KDZ+AMlbVCGTG+dZMWtc3mgku8=";
  };

  cmakeFlags = old.cmakeFlags ++ [
    "-DBUILD_TESTING=OFF"
    "-DCMAKE_BUILD_TYPE=Release"
  ];
})
