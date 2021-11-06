cmake_minimum_required( VERSION 3.16 )

set( CMAKE_EXPORT_COMPILE_COMMANDS ON )

if( ${CMAKE_UTILS} STREQUAL * )
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
endif()

foreach( UTIL ${CMAKE_UTILS} )
	if( UTIL MATCHES CLANG_BUILD_ANALYZER )
		option( BUILD_ANALYZER "Enable Clang build statistics" OFF )
	endif()
	if( UTIL MATCHES CLANG_FORMAT
	OR  UTIL MATCHES CLANG_TIDY
		)
		option( STATIC_WERROR "Change warning into errors in the static analysis tools" OFF )
	endif()
	if( UTIL MATCHES CLANG_FORMAT
	OR  UTIL MATCHES CLANG_TIDY
	OR  UTIL MATCHES CPPCHECK
	OR  UTIL MATCHES IWYU
	OR  UTIL MATCHES LIZARD
	OR  UTIL MATCHES UNCRUSTIFY
		)
		option( STATIC_ERROR "Do not tolerate errors in the static analysis tools" OFF )
	endif()
	if( UTIL MATCHES CODECHECKER )
		option( CODECHECKER_REPORT "Tools that are supported as analyzers produce CodeChecker reports" OFF )
	endif()
	if( UTIL MATCHES COVERAGE )
		option( COVERAGE "Enable coverage for the current build type, prefer to use the Coverage build type" OFF )
		option( SONAR "The coverage target will produce SonarQube reports instead of console / HTML" OFF )
		option( COVERAGE_GLOBAL_ONLY "When calling the 'coverage' target, do not show the dependant per target reports. The counterpart is the creation of intermediate targets" OFF )
		option( COVERAGE_GCOVR_VERBOSE "Print gcovr reports in terminal while generating sonarqube coverage reports" OFF )
	endif()
	if( UTIL MATCHES DOXYGEN )
		option( DOXYGEN_MCSS "Enable m.css Doxygen reports" OFF )
		set( MCSS_VERSION "" CACHE STRING "M.CSS git tag" )
	endif()
	if( UTIL MATCHES LIBFUZZER )
		option( LIBFUZZER "Enable LibFuzzer" OFF )
	endif()
	if( UTIL MATCHES SANITIZERS )
		set( SANITIZER
			""
			CACHE
			STRING
			"Compile with a sanitizer. Options are: ASAN, AUBSAN, CFISAN, LSAN, MSAN, MWOSAN, TSAN, UBSAN"
			)
	endif()
	if( UTIL MATCHES UNCRUSTIFY )
		option( UNCRUSTIFY_DIFF "Show diff of the suggested modifications while running uncristify" ON )
	endif()
endforeach()

foreach( UTIL ${CMAKE_UTILS} )
	if( UTIL MATCHES COVERAGE )
		include( Coverage )
	elseif( UTIL MATCHES CODECHECKER )
		include( CodeChecker )
	elseif( UTIL MATCHES DOXYGEN )
		include( Doxygen )
	elseif( UTIL MATCHES SANITIZERS )
		include( Sanitizers )
	elseif( UTIL MATCHES CLANG_BUILD_ANALYZER )
		include( ClangBuildAnalyzer )
	elseif( UTIL MATCHES LATEX )
		include( Latex )
	elseif( UTIL MATCHES IWYU )
		include( IncludeWhatYouUse )
	elseif( UTIL MATCHES LIZARD )
		include( Lizard )
	elseif( UTIL MATCHES LIBFUZZER ) # Depends on Sanitizers
		include( LibFuzzer )
	elseif( UTIL MATCHES CPPCHECK )
		include( Cppcheck )
	elseif( UTIL MATCHES UNCRUSTIFY )
		include( Uncrustify )
	elseif( UTIL MATCHES CLANG_TIDY )
		include( ClangTidy )
	elseif( UTIL MATCHES CLANG_FORMAT )
		include( ClangFormat )
	endif()
endforeach()
