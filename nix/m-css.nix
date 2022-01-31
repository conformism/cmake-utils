{ stdenv
, lib
, fetchFromGitHub
}:

stdenv.mkDerivation {
  name = "m-css";

  src = fetchFromGitHub {
    owner = "mosra";
    repo = "m.css";
    rev = "d44d460";
    sha256 = "sha256-n2ajNgDkbeJh4gE/W/1QhCwYOuXCsYxLOtII6RVh3Ic=";
  };

#    install -d $out/opt/m.css/
#    install -D ./* -t $out/opt/m.css/
  installPhase = ''
    mkdir -p $out/opt/m.css/
    mkdir -p $out/bin
    cp -r ./* $out/opt/m.css/
    ln -s $out/opt/m.css/documentation/doxygen.py $out/bin/doxygen.py
  '';

  meta = {
    homepage = "https://mcss.mosra.cz/";
    description = "A no-nonsense, no-JavaScript CSS framework, site and documentation theme for content-oriented websites";
    license = lib.licenses.mit;
    maintainers = [];
  };
}
