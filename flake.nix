{
  description = "CMake Utilities";

  nixConfig.bash-prompt-suffix = "(cmake-utils) ";

  inputs = {
#    nixpkgs.url = "flake:nixpkgs";
    nixpkgs.url = "github:NixOS/nixpkgs";

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
        packages = [ pkgs.cmake-utils-full ];
        inputsFrom = [ pkgs.cmake-utils-full ];
      };
    };

    packages = {
      default = pkgs.cmake-utils;
      cmake-utils = pkgs.cmake-utils;
      cmake-utils-full = pkgs.cmake-utils-full;
    };
  }) // {
    overlays = {
      pkgs = final: prev: {
        cmake-utils = prev.callPackage ./default.nix { doxygen = final.doxygen-clang; };
        cmake-utils-full = final.cmake-utils.override {
          with-catch3 = true;
          with-clang-build-analyzer = true;
          with-clang-tools = true;
          with-codechecker = true;
          with-coverage = true;
          with-cppcheck = true;
          with-doxygen = true;
          with-icon = true;
          with-include-what-you-use = true;
          with-lizard = true;
          with-m-css = true;
          with-sonar = true;
          with-uncrustify = true;
        };
        clang-build-analyzer = prev.callPackage ./nix/clang-build-analyzer.nix {};
        codechecker = prev.callPackage ./nix/codechecker.nix {};
        coverxygen = prev.callPackage ./nix/coverxygen.nix { doxygen = final.doxygen-clang; };
        doxygen-clang = prev.callPackage ./nix/doxygen.nix {};
        lizard = prev.callPackage ./nix/lizard.nix {};
        m-css = prev.callPackage ./nix/m-css.nix { doxygen = final.doxygen-clang; };
        uncrustify = prev.callPackage ./nix/uncrustify.nix { inherit (prev) uncrustify; };
      };
    };
  };
}
