{ lib
, python3Packages
}:

with python3Packages;

buildPythonPackage rec {
  pname = "lizard";
  version = "1.17.9";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-du4OYx2YW+od1lIaA8bC+p3OWiJIs9JsSYkOnghbeu0=";
  };

  doCheck = false;

  meta = {
    homepage = "https://github.com/terryyin/lizard";
    description = ''
      A simple code complexity analyser without caring about the C/C++ header
      files or Java imports, supports most of the popular languages.;
    '';
    license = lib.licenses.mit;
    maintainers = [];
  };
}
