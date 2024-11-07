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
    pkgs = nixpkgs.legacyPackages.${system}.extend self.overlays.pkgs;

  in {
    devShells = {
      default = pkgs.mkShell {
        packages = [ pkgs.cmake-utils-all ];
        inputsFrom = [ pkgs.cmake-utils-all ];
      };
    };

    packages = {
      default = pkgs.cmake-utils;
      cmake-utils = pkgs.cmake-utils;
      cmake-utils-all = pkgs.cmake-utils-all;
    };
  }) // {
    overlays = {
      pkgs = final: prev: {
        cmake-utils = prev.callPackage ./default.nix {};
        cmake-utils-all = prev.callPackage ./default.nix { need-all = true; };
      };
    };
  };
}
