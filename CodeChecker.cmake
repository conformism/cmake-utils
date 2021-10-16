find_program( CODECHECKER NAMES CodeChecker codechecker )
if( CODECHECKER )
	message( STATUS "Found CodeChecker: ${CODECHECKER}" )
else()
	message( STATUS "Not found CodeChecker: codechecker targets disabled" )
endif()
if( CODECHECKER_REPORT )
	find_program( REPORT_CONVERTER NAMES report-converter codechecker.report-converter )
	if( REPORT_CONVERTER )
		message( STATUS "Found report-converter: ${REPORT_CONVERTER}" )
	else()
		message( STATUS "Not found report-converter: codechecker targets disabled" )
	endif()

	find_program( TEST_COMMAND NAMES test )
	if( TEST_COMMAND )
		message( STATUS "Found test: ${TEST_COMMAND}" )
	else()
		message( STATUS "Not found test: codechecker targets disabled" )
	endif()
endif()

################################################################################
# static_analysis_codechecker(
#                             [TARGET target]
#                             [NO_CTU]
#                             [ADDITIONAL_OPTIONAL_REPORTS dir1 [dir2] ...]
#                             [SKIP arg1 [arg2] ...]
#                             [ARGS arg1 [arg2] ...]
#                             )
# [TARGET]
#       Target to analyse. Will set codechecker target name in consequences.
# [NO_CTU]
#       Disable cross translation unit analysis.
# [ADDITIONAL_OPTIONAL_REPORTS]
#       Specify other analysis reports, generated by tools supported by the
#       report-converter program. Enable report export from those tools with
#       the CODECHECKER_REPORT option.
# [SKIP]
#       Specify files to analyze regarding the codechecker skipfile syntax.
# [ARGS]
#       Specify codechecker analyze command line arguments.
################################################################################
function( static_analysis_codechecker )
	set( OPTIONS GLOBAL NO_CTU )
	set( ONEVALUEARGS TARGET )
	set( MULTIVALUEARGS SKIP ARGS ADDITIONAL_OPTIONAL_REPORTS )
	cmake_parse_arguments( CODECHECKER
		"${OPTIONS}"
		"${ONEVALUEARGS}"
		"${MULTIVALUEARGS}"
		${ARGN}
		)

	if( CODECHECKER_GLOBAL AND CODECHECKER_TARGET )
		message( ERROR " static_analysis_codechecker() : Use GLOBAL or TARGET but not both!" )
	elseif( CODECHECKER_GLOBAL )
		set( TARGET_NAME
			codechecker
			)
	elseif( CODECHECKER_TARGET )
		set( TARGET_NAME
			${CODECHECKER_TARGET}_codechecker
			)
	else()
		message( ERROR " static_analysis_codechecker() : Specify a target!" )
	endif()

	if( NOT CODECHECKER_NO_CTU )
		set( CTU_ARG --ctu )
	endif()

	set( TARGET_DIR
		"${CMAKE_CURRENT_BINARY_DIR}/CMakeFiles/${TARGET_NAME}.dir"
		)

	if( CODECHECKER_ADDITIONAL_OPTIONAL_REPORTS )
		set( ARE_OPTIONAL_REPORTS "true" )
	else()
		set( ARE_OPTIONAL_REPORTS "false" )
	endif()

	foreach( LINE ${CODECHECKER_SKIP} )
		list( APPEND
			SKIP
			"${LINE}\n"
			)
	endforeach()
	file( WRITE
		"${TARGET_DIR}/skipfile"
		${SKIP}
		)

	add_custom_target( ${TARGET_NAME}
		DEPENDS "${TARGET_DIR}/skipfile"
		COMMAND ${CODECHECKER} analyze
			-i "${TARGET_DIR}/skipfile"
			-o "${TARGET_DIR}/codechecker_reports"
			${CTU_ARG}
			${CODECHECKER_ARGS}
		COMMENT "Run CodeChecker analyzers, generate report"
		)

	if( CODECHECKER_REPORT )
		foreach( REPORT_DIR ${CODECHECKER_ADDITIONAL_OPTIONAL_REPORTS} )
			add_custom_command( TARGET ${TARGET_NAME}
				POST_BUILD
				COMMAND
					${TEST_COMMAND} -d ${REPORT_DIR}
					&& ${CMAKE_COMMAND} -E copy_directory
						${CODECHECKER_ADDITIONAL_OPTIONAL_REPORTS}
						"${TARGET_DIR}/codechecker_reports"
					|| ${CMAKE_COMMAND} -E true
				)
		endforeach()
	endif()

	add_custom_command( TARGET ${TARGET_NAME}
		POST_BUILD
		COMMAND ${CODECHECKER} parse
			-o "${TARGET_DIR}/html"
			--trim-path-prefix "${CMAKE_SOURCE_DIR}"
			-e html
			# TODO Would very simplify but does not seems to work properly (bug?)
#			${CODECHECKER_ADDITIONAL_OPTIONAL_REPORTS}
			"${TARGET_DIR}/codechecker_reports"
		)

	add_custom_command( TARGET ${TARGET_NAME}
		POST_BUILD
		COMMENT "${TARGET_DIR}/html/index.html"
		)
endfunction()
