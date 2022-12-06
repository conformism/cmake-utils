{ uncrustify
, fetchFromGitHub
, cmake
, python3
}:

uncrustify.overrideAttrs (old: rec {
  version = "0.76.0";

  src = fetchFromGitHub {
    owner = old.pname;
    repo = old.pname;
    rev = "${old.pname}-${version}";
    sha256 = "sha256-th3lp4WqqruHx2/ym3I041y2wLbYM1b+V6yXNOWuUvM=";
  };

  nativeBuildInputs = [ cmake python3 ];

  cmakeFlags = [
    "-DCMAKE_BUILD_TYPE=Release"
  ];
})
