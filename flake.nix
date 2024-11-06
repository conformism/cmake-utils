{
  description = "CMake Utilities";

  nixConfig.bash-prompt-suffix = "(cmake-utils) ";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/22.11";

    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self
  , nixpkgs
  , flake-utils
  }:
  flake-utils.lib.eachDefaultSystem (system:
  let
    pkgs = nixpkgs.legacyPackages.${system};
    lib = nixpkgs.lib;

    this-package = pkgs.callPackage ./default.nix {};
    this-package-all = pkgs.callPackage ./default.nix { need-all = true; };

  in {
    overlays = {
      pkgs = final: prev: {
        cmake-utils = this-package;
        cmake-utils-all = this-package-all;
      };
    };

    devShells = {
      default = pkgs.mkShell {
        packages = [ this-package-all ];
        inputsFrom = [ this-package-all ];
      };
    };

    packages = {
      default = this-package;
      cmake-utils = this-package;
      cmake-utils-all = this-package-all;
    };
  });
}
