# CMake Utils

## Description

This is a collection of CMake utilities to include in a C++ project a set of usefull development tools.

You can include it in a project as Git submodule or using [CPM](https://github.com/cpm-cmake/CPM.cmake).

## Included tools

- [Lizard](https://github.com/terryyin/lizard)
- [IWYU](https://github.com/include-what-you-use/include-what-you-use)
- [Uncrustify](https://github.com/uncrustify/uncrustify)
- [Cppcheck](https://github.com/danmar/cppcheck)
- [Clang-Format](https://clang.llvm.org/docs/ClangFormat.html)
- [Clang-Tidy](https://clang.llvm.org/extra/clang-tidy/)
- [CodeChecker](https://github.com/Ericsson/codechecker) ([Clang-Static-Analyzer](https://clang-analyzer.llvm.org/))
- [ClangBuildAnalyzer](https://github.com/aras-p/ClangBuildAnalyzer)
- LaTeX (works with XeLaTeX compiler, [minted](https://www.ctan.org/pkg/minted) & [tikz](https://www.ctan.org/pkg/pgf) packages)
- [LibFuzzer](https://www.llvm.org/docs/LibFuzzer.html)
- Sanitizers
- [Lcov](http://ltp.sourceforge.net/coverage/lcov.php) / [Llvm-cov](https://clang.llvm.org/docs/SourceBasedCodeCoverage.html) / [Gcovr](https://github.com/gcovr/gcovr) (works with [Catch2](https://github.com/catchorg/Catch2), with [SonarQube](https://www.sonarqube.org/) / [SonarCloud](https://sonarcloud.io) integration)

## Inclusion

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

set( CMAKE_UTILS
	CLANG_BUILD_ANALYZER
	CLANG_FORMAT
	CLANG_TIDY
	CODECHECKER
	COVERAGE
	CPPCHECK
	IWYU
	LATEX
	LIBFUZZER
	LIZARD
	SANITIZERS
	UNCRUSTIFY
	)

# Or all tools at once
set( CMAKE_UTILS * )

include( CMakeUtils )
```
