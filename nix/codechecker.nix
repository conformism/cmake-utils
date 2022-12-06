{ lib
, python3Packages
, clang
}:

with python3Packages;

buildPythonPackage rec {
  pname = "codechecker";
  version = "6.21.0";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-V8NH9yZzqYcM5CBftImWO6wCTNY2YOZWW4a5gzMaSXU=";
  };

  doCheck = false;

  propagatedBuildInputs = [
    alembic
    clang
    GitPython
    lxml
    mypy-extensions
    portalocker
    psutil
    pyyaml
    sqlalchemy
    thrift
  ];

  prePatch = ''
    substituteInPlace setup.py --replace "list(get_requirements())" "[]"
    substituteInPlace build_dist/CodeChecker/lib/python3/tu_collector/tu_collector.py --replace "zipfile.ZipFile(zip_file, 'a')" "zipfile.ZipFile(zip_file, 'a', strict_timestamps=False)"
  '';

  meta = {
    homepage = "https://github.com/Ericsson/codechecker";
    description = ''
      CodeChecker is an analyzer tooling, defect database and viewer extension
      for the Clang Static Analyzer and Clang Tidy;
    '';
    license = lib.licenses.asl20;
    maintainers = [];
  };
}
