{ lib
, python3Packages
}:

with python3Packages;

buildPythonPackage rec {
  pname = "lizard";
  version = "1.17.10";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-YteKzWRyS+KLX0qiemMN+ktK+9FZbR8l1a0cGjoHWtw=";
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
