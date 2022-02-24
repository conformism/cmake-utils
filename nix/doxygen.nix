{ doxygen
, cmake
, llvmPackages
}:

doxygen.overrideAttrs (old: rec {
  nativeBuildInputs = old.nativeBuildInputs ++ [
    llvmPackages.libclang
    llvmPackages.llvm
  ];

  cmakeFlags = old.cmakeFlags ++ [
    "-DCMAKE_BUILD_TYPE=Release"
    "-Duse_libclang=ON"
  ];
})
