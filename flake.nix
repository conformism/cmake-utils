{
  description = "CMake Utilities.";

  nixConfig.bash-prompt-suffix = "(cmake-utils) ";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/8cec3cc";

    utils.url = "github:numtide/flake-utils";
    utils.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self
  , nixpkgs
  , ...
  }@inputs:
  inputs.utils.lib.eachDefaultSystem (system:
  let
    pkgs = import nixpkgs { inherit system; };
    this-package-dev = pkgs.callPackage ./default.nix { inherit pkgs; need-all = true; };
    this-package = pkgs.callPackage ./default.nix { inherit pkgs; };

  in {
    devShell = pkgs.mkShell rec {
      packages = [ this-package-dev ];
      inputsFrom = [ this-package-dev ];
    };

    defaultPackage = this-package;
  });
}
