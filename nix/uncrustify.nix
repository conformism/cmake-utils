{ uncrustify
, fetchFromGitHub
, cmake
, python3
}:

uncrustify.overrideAttrs (old: rec {
  name = "${old.product}-${version}";
  version = "0.74.0";

  src = fetchFromGitHub {
    owner = old.product;
    repo = old.product;
    rev = name;
    sha256 = "sha256-rctITiwWLdM6QY/vpdbWWs0rqFe/ww3c0v7L/ivciGw=";
  };

  nativeBuildInputs = [ cmake python3 ];

  cmakeFlags = [
    "-DCMAKE_BUILD_TYPE=Release"
  ];
})
