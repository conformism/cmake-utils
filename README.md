# CMake Utils

## Description

This is a collection of CMake utilities to include in a C++ project a set of usefull development tools.

You can include it in a project as Git submodule or using [CPM](https://github.com/cpm-cmake/CPM.cmake).

## Included tools

- [Lizard](https://github.com/terryyin/lizard)
- [IWYU](https://github.com/include-what-you-use/include-what-you-use)
- [Cppcheck](https://github.com/danmar/cppcheck)
- [Clang-Format](https://clang.llvm.org/docs/ClangFormat.html)
- [Clang-Tidy](https://clang.llvm.org/extra/clang-tidy/)
- [ClangBuildAnalyzer](https://github.com/aras-p/ClangBuildAnalyzer)
- LaTeX (works with XeLaTeX compiler, [minted](https://www.ctan.org/pkg/minted) & [tikz](https://www.ctan.org/pkg/pgf) packages)

## Usage

### With CPM

```cmake
include( CPM )

CPMAddPackage(
	NAME cmake-utils
	GITHUB_REPOSITORY conformism/cmake-utils
	GIT_TAG main
	DOWNLOAD_ONLY
	)

list( APPEND CMAKE_MODULE_PATH
	"${FETCHCONTENT_BASE_DIR}/cmake-utils-src"
	)

include( <Tool> )
```
