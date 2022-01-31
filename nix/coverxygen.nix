{ lib
, python3Packages
, doxygen
}:

with python3Packages;

buildPythonPackage rec {
  pname = "coverxygen";
  version = "1.7.0";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-8dTMr1jx0rv7XJnY5kSyZ8Br3OmPTR7jwBmAaJ13F8s=";
  };

  propagatedBuildInputs = [ doxygen ];

  meta = {
    homepage = "https://github.com/psycofdj/coverxygen";
    description = "Generate doxygen's documentation coverage report";
    license = lib.licenses.gpl3;
    maintainers = [];
  };
}
