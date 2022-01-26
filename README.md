# CMake Utils

## Description

This is a collection of CMake utilities to include in a C++ project a set of usefull development tools.

You can include it in a project as Git submodule or using [CPM](https://github.com/cpm-cmake/CPM.cmake).

## Included tools

- [Lizard](https://github.com/terryyin/lizard)
- [IWYU](https://github.com/include-what-you-use/include-what-you-use)
- [Uncrustify](https://github.com/uncrustify/uncrustify)
- [Cppcheck](https://github.com/danmar/cppcheck)
- [ClangBuildAnalyzer](https://github.com/aras-p/ClangBuildAnalyzer)
- [Clang-Format](https://clang.llvm.org/docs/ClangFormat.html)
- [Clang-Tidy](https://clang.llvm.org/extra/clang-tidy/)
- [CodeChecker](https://github.com/Ericsson/codechecker) ([Clang-Static-Analyzer](https://clang-analyzer.llvm.org/))
- LaTeX (works with XeLaTeX compiler, [minted](https://www.ctan.org/pkg/minted) & [tikz](https://www.ctan.org/pkg/pgf) packages)
- [LibFuzzer](https://www.llvm.org/docs/LibFuzzer.html)
- Sanitizers
- [Lcov](http://ltp.sourceforge.net/coverage/lcov.php) / [Llvm-cov](https://clang.llvm.org/docs/SourceBasedCodeCoverage.html) / [Gcovr](https://github.com/gcovr/gcovr) (works with [Catch2](https://github.com/catchorg/Catch2), with [SonarQube](https://www.sonarqube.org/) / [SonarCloud](https://sonarcloud.io) integration)
- [Doxygen](https://www.doxygen.nl/index.html) (with [Coverxygen](https://github.com/psycofdj/coverxygen) and [m.css](https://mcss.mosra.cz/documentation/doxygen/) integration)

## Inclusion with CPM

```cmake
include( CPM )

CPMAddPackage(
	NAME cmake-utils
	GITHUB_REPOSITORY conformism/cmake-utils
	GIT_TAG main
	DOWNLOAD_ONLY
	)

list( PREPEND CMAKE_MODULE_PATH
	"${FETCHCONTENT_BASE_DIR}/cmake-utils-src/Modules"
	)

set( CMAKE_UTILS
	CLANG_BUILD_ANALYZER
	CLANG_FORMAT
	CLANG_TIDY
	CODECHECKER
	COVERAGE
	CPPCHECK
	DOXYGEN
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

## Options

For more informations about those options, take a look to the utils detail paragraph.

| Option | Default | Description | Concerned utils |
|-|-|-|-|
| `BUILD_ANALYZER`         | `OFF` | Enable Clang build statistics                                                                                                 | `CLANG_BUILD_ANALYZER` |
| `STATIC_WERROR`          | `OFF` | Change warning into errors in the static analysis tools                                                                  | `CLANG_FORMAT` `CLANG_TIDY` |
| `STATIC_ERROR`           | `OFF` | Do not tolerate errors in the static analysis tools                              | `CLANG_FORMAT` `CLANG_TIDY` `CPPCHECK` `IWYU` `LIZARD` `UNCRUSTIFY` |
| `CODECHECKER_REPORT`     | `OFF` | Tools that are supported as analyzers produce CodeChecker reports                                               | `CODECHECKER` `CPPCHECK` `LIBFUZZER` |
| `COVERAGE`               | `OFF` | Enable coverage for the current build type, prefer to use the Coverage build type                                                         | `COVERAGE` |
| `SONAR`                  | `OFF` | The coverage target will produce SonarQube reports instead of console / HTML                                                              | `COVERAGE` |
| `COVERAGE_GLOBAL_ONLY`   | `OFF` | When calling the 'coverage' target, do not show the dependant per target reports. The counterpart is the creation of intermediate targets | `COVERAGE` |
| `COVERAGE_GCOVR_VERBOSE` | `OFF` | Print gcovr reports in terminal while generating sonarqube coverage reports                                                               | `COVERAGE` |
| `DOXYGEN_MCSS`           | `OFF` | Enable m.css Doxygen reports                                                                                                              | `DOXYGEN`  |
| `MCSS_VERSION`           | ` `   | M.CSS git tag                                                                                                                             | `DOXYGEN`  |
| `LATEX_VERBOSE`          | `OFF` | Show LaTeX compiler output messages.                                                                                                      | `LATEX`    |
| `LIBFUZZER`              | `OFF` | Enable LibFuzzer                                                                                                                         | `LIBFUZZER` |
| `UNCRUSTIFY_DIFF`        | `ON`  | Show diff of the suggested modifications while running uncrustify                                                                       | `UNCRUSTIFY` |
| `SANITIZER`              | ` `   | Compile with a sanitizer. Options are: `ASAN`, `AUBSAN`, `CFISAN`, `LSAN`, `MSAN`, `MWOSAN`, `TSAN`, `UBSAN`                | `SANITIZERS` `LIBFUZZER` |

## Utils API

### ClangBuildAnalyzer

```cmake
enable_clang_build_analyzer(
	TARGET <target>
	)
```

- `TARGET` : Target to analyse.

### ClangFormat

```cmake
clang_format(
	TARGET <target>
	ADDITIONAL_FILES
		<file1>
		<...>
	ARGS
		<arg1>
		<...>
	)
```

- `TARGET` : Target to analyse. Every source file will be analysed.
- `ADDITIONAL_FILES` : Specify other files to analyse, headers for instance.
- `ARGS` : Specify command line arguments.

### ClangTidy

```cmake
clang_tidy(
	TARGET <target>
	ADDITIONAL_FILES
		<file1>
		<...>
	ARGS
		<arg1>
		<...>
	)
```

- `TARGET` : Target to analyse. Every source file will be analysed.
- `ADDITIONAL_FILES` : Specify other files to analyse, headers for instance.
- `ARGS` : Specify command line arguments.

### CodeChecker

```cmake
codechecker(
	TARGET <target>
	GLOBAL
	NO_CTU
	ADDITIONAL_OPTIONAL_REPORTS
		<dir1>
		<...>
	SKIP
		<arg1>
		<...>
	ARGS
		<arg1>
		<...>
	)
```

- `TARGET` : Target to analyse. Will set codechecker target name in consequences.
- `GLOBAL` : Create a global codechecker target instead of a per-target one, should be prefered to cover a whole project.
- `NO_CTU` : Disable cross translation unit analysis.
- `ADDITIONAL_OPTIONAL_REPORTS` : Specify other analysis reports, generated by tools supported by the report-converter program. Enable report export from those tools with the `CODECHECKER_REPORT` option.
- `SKIP` : Specify files to analyse regarding the codechecker skipfile syntax.
- `ARGS` : Specify codechecker analyse command line arguments.

### Coverage

```cmake
coverage(
	TARGET_TO_RUN <target>
	TARGETS_TO_COVER
		<target1>
		<...>
	EXCLUDE_FROM_ALL
	ARGS_GCOVR
		<arg1>
		<...>
	)
```

- `TARGET_TO_RUN` : Target to run, typically a unittest executable.
- `TARGETS_TO_COVER` : Targets to produce coverage reports on, typically libraries tested by the unittest executable.
- `EXCLUDE_FROM_ALL` : Exclude the coverage target from global reports produced by 'coverage' target.
- `ARGS_GCOVR` : Arguments to pass to gcovr (used for sonarqube reports), especially usefull to specify source coverage filters (`-e` and `-f`) as this is not automatically done as for lcov and llvm-cov.

```cmake
coverage_global()
```

### Cppcheck

```cmake
cppcheck(
	TARGET <target>
	ADDITIONAL_FILES
		<file1>
		<...>
	ARGS
		<arg1>
		<...>
	)
```

- `TARGET` : Target to analyse. Every source file will be analysed.
- `ADDITIONAL_FILES` : Specify other files to analyse, headers for instance.
- `ARGS` : Specify command line arguments.

### Doxygen

```cmake
doxygen(
	TARGET <target>
	DOXYFILE <file>
	MCSS_CONF <file>
	EXCLUDE_FROM_ALL
	TARGETS_TO_DOC
		<target1>
		<...>
	ADDITIONAL_FILES
		<file1>
		<...>
	ARGS_COVERXYGEN
		<arg1>
		<...>
	)
```

- `TARGET` : Target name, better add `_dox` suffix.
- `TARGETS_TO_DOC` : Targets to run Doxygen on.
- `ADDITIONAL_FILES` : Specify other files to analyse, headers for instance.
- `DOXYFILE` : Doxyfile path. Following values are required:
  - `CLANG_DATABASE_PATH = @DOXYGEN_CLANG_DATABASE_PATH@`
  - `GENERATE_HTML = @DOXYGEN_GENERATE_HTML@`
  - `GENERATE_XML = @DOXYGEN_GENERATE_XML@`
  - `HTML_OUTPUT = @DOXYGEN_HTML_OUTPUT@`
  - `OUTPUT_DIRECTORY = @DOXYGEN_OUTPUT_DIRECTORY@`
  - `XML_OUTPUT = @DOXYGEN_XML_OUTPUT@`
  - `XML_PROGRAMLISTING = @DOXYGEN_XML_PROGRAMLISTING@`
- `MCSS_CONF` : M.CSS configuration file path. Following values are required:
  - `DOXYFILE = @MCSS_DOXYFILE@`
  - `@MCSS_DOXYGEN_COVERAGE_INDEX@` may be used in `LINKS_NAVBAR1` or `LINKS_NAVBAR2` to add a link to Doxygen coverage Lcov report.
- `ARGS_COVERXYGEN` : Specify Coverxygen command line arguments. `--src-dir` is required.
- `EXCLUDE_FROM_ALL` : Exclude the Doxygen target from global call to `dox` target.

### IncludeWhatYouUse

```cmake
iwyu(
	TARGET <target>
	ADDITIONAL_FILES
		<file1>
		<...>
	ARGS
		<arg1>
		<...>
	)
```

- `TARGET` : Target to analyse. Every source file will be analysed.
- `ADDITIONAL_FILES` : Specify other files to analyse, headers for instance.
- `ARGS` : Specify command line arguments.

### Latex

```cmake
compile_latex_file( <name>
	OUTPUT
		<output2>
		<...>
	DESTINATION <destination_dir>
	SOURCE <source_dir>
	TEXINPUTS <texinputs>
	SUBDIRS
		<subdir1>
		<...>
	REGISTER_TO <var>
	DEPENDS
		<file1>
		<...>
	SHELL_ESCAPE
	MINTED
	)
```

- `OUTPUT` : `${destination_dir}/${name}.pdf` is the default output file. You can add some others with this flag.
- `DESTINATION` : Directory where output pdf file and byproduct files are created. Default is : `${CMAKE_CURRENT_BINARY_DIR}`.
- `SOURCE` Directory where main tex file is located. Default is : `${CMAKE_CURRENT_SOURCE_DIR}`.
- `TEXINPUTS` : Directories where other files (tex files, images, classes, etc.) are included from. Default contains current directory (at build time) and LaTex system directories. Should be set as long as main tex file includes other files **AND** you don't execute the build command where the main tex file is located. Or if a tex file includes another file from elsewhere than the main tex file directory. Syntax is : `dir1:dir2:...`
- `SUBDIRS` : Directories where other tex files are located. Should be a relative path from a `TEXINPUTS` location. The purpose of this flag is to create a build tree that correspond to the source tree. For example, if a tex file contains this `\include{chapters/chapter2}`, add `chapters` to subdirs.
- `REGISTER_TO` : Append output pdf file to var. To the tex file to be compiled, at least one target must `DEPENDS` on its output file. Avoid making more than one target `DEPENDS` on one output pdf file, instead create dependencies between other dependant targets and the one that wraps the tex file compilation.
- `DEPENDS` : By default a rebuild of the LaTeX document is triggerd only if the main tex file is newer than the output file. This argument let's you trigger a rebuild on additional input files' timestamp.
- `SHELL_ESCAPE` : Append `--shell-escape` to the LaTex compiler.
- `MINTED` : Use it only if you use the LaTex package Minted **AND** you override `DESTINATION`. Defines `\mintedoutputdir` to set the Minted package argument `outputdir`. So you can include Minted this way : `\usepackage[outputdir=\mintedoutputdir]{minted}`.

### LibFuzzer

```cmake
add_libfuzzer_target(
	TARGET <target>
	SOURCE <file>
	TARGET_TO_FUZZ <target>
	EXCLUDE_FROM_ALL
	ARGS
		<arg1>
		<...>
	)
```
- `TARGET` : Fuzzing target name.
- `SOURCE` : Source file containing the libfuzzer entry point.
- `TARGET_TO_FUZZ` : Target tested by the fuzzing target.
- `EXCLUDE_FROM_ALL` : Exclude the fuzzing target from global call to `fuzz` target.
- `ARGS` : Arguments to pass to the fuzzing target run.

### Lizard

```cmake
lizard(
	TARGET <target>
	ADDITIONAL_FILES
		<file1>
		<...>
	ARGS
		<arg1>
		<...>
	)
```

- `TARGET` : Target to analyse. Every source file will be analysed.
- `ADDITIONAL_FILES` : Specify other files to analyse, headers for instance.
- `ARGS` : Specify command line arguments.

### Sanitizers

```cmake
enable_sanitizers(
	TARGET <target>
	)
```

- `TARGET` : Target to sanitize.

### Uncrustify

```cmake
uncrustify(
	TARGET <target>
	ADDITIONAL_FILES
		<file1>
		<...>
	ARGS
		<arg1>
		<...>
	)
```

- `TARGET` : Target to analyse. Every source file will be analysed.
- `ADDITIONAL_FILES` : Specify other files to analyse, headers for instance.
- `ARGS` : Specify command line arguments.
