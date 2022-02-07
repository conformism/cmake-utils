{ lib
, python3Packages
, clang
}:

with python3Packages;

buildPythonPackage rec {
  pname = "codechecker";
  version = "6.18.2";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-x5OhlR9YuvC6QU5B9kWK9ikvZCjGmehLi3HaFh2DTws=";
  };

  doCheck = false;

  propagatedBuildInputs = [
    mypy-extensions
    alembic
    sqlalchemy
    psutil
    pyyaml
    portalocker
    GitPython
    thrift
    lxml
    clang
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
