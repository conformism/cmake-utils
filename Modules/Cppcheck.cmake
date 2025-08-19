find_program( CPPCHECK NAMES cppcheck )
if( CPPCHECK )
	set( CMakeUtils_Cppcheck_FOUND ON )
	message( STATUS "Found Cppcheck: ${CPPCHECK}" )
	add_custom_target( cppcheck )
else()
	set( CMakeUtils_Cppcheck_FOUND OFF )
	message( STATUS "Not found Cppcheck: cppcheck targets disabled" )
endif()

mark_as_advanced( CPPCHECK )

################################################################################
# cppcheck(
#          [TARGET target]
#          [ADDITIONAL_FILES file1 [file2] ...]
#          [ARGS arg1 [arg2] ...]
#          )
# [TARGET]
#       Target to analyse. Every source file will be analysed.
# [ADDITIONAL_FILES]
#       Specify other files to analyse, headers for instance.
# [ARGS]
#       Specify command line arguments.
################################################################################
function( cppcheck )
	set( OPTIONS )
	set( ONEVALUEARGS TARGET )
	set( MULTIVALUEARGS ADDITIONAL_FILES ARGS )
	cmake_parse_arguments( CPPCHECK
		"${OPTIONS}"
		"${ONEVALUEARGS}"
		"${MULTIVALUEARGS}"
		${ARGN}
		)

	if( STATIC_ERROR )
		set( CPPCHECK_ERROR 1 )
	else()
		set( CPPCHECK_ERROR 0 )
	endif()
	if( CPPCHECK_TARGET )
		get_target_property( CPPCHECK_SRC ${CPPCHECK_TARGET} SOURCES )
		get_target_property( CPPCHECK_STD ${CPPCHECK_TARGET} CXX_STANDARD )
	else()
		message( FATAL_ERROR "Specify a target!" )
	endif()
	foreach( ARG ${CPPCHECK_ARGS} )
		list( APPEND ALL_ARGS ${ARG} )
	endforeach()

	if( CPPCHECK )
		add_custom_target( ${CPPCHECK_TARGET}_cppcheck
			SOURCES ${CPPCHECK_SRC} ${CPPCHECK_ADDITIONAL_FILES}
#			COMMENT "Cppcheck"
			)

		if( CODECHECKER_REPORT AND CODECHECKER AND REPORT_CONVERTER )
			set( CODECHECKER_ARGS
				--plist-output="${CMAKE_CURRENT_BINARY_DIR}/CMakeFiles/${CPPCHECK_TARGET}_cppcheck.dir/reports"
				)

			add_custom_command(
				TARGET ${CPPCHECK_TARGET}_cppcheck
				POST_BUILD
				COMMAND ${CMAKE_COMMAND} -E make_directory
					"${CMAKE_CURRENT_BINARY_DIR}/CMakeFiles/${CPPCHECK_TARGET}_cppcheck.dir/reports"
				)
		endif()

		list( APPEND CPPCHECK_SRC ${CPPCHECK_ADDITIONAL_FILES} )
		foreach( SRC ${CPPCHECK_SRC} )
			add_custom_command(
				TARGET ${CPPCHECK_TARGET}_cppcheck
				POST_BUILD
				COMMAND ${CPPCHECK}
					--error-exitcode=1
					--std=c++${CPPCHECK_STD}
					${CODECHECKER_ARGS}
					${CPPCHECK_ARGS}
					${SRC}
					|| exit ${CPPCHECK_ERROR}
				COMMENT "Cppcheck ${SRC}"
				)
		endforeach()

		if( CODECHECKER_REPORT AND CODECHECKER AND REPORT_CONVERTER )
			add_custom_command(
				TARGET ${CPPCHECK_TARGET}_cppcheck
				POST_BUILD
				COMMAND ${REPORT_CONVERTER}
					-t cppcheck
					-o "${CMAKE_CURRENT_BINARY_DIR}/CMakeFiles/${CPPCHECK_TARGET}_cppcheck.dir/codechecker_reports"
					"${CMAKE_CURRENT_BINARY_DIR}/CMakeFiles/${CPPCHECK_TARGET}_cppcheck.dir/reports"
				COMMENT "CodeChecker Cppcheck report export"
				)

			set_property(
				TARGET ${CPPCHECK_TARGET}_cppcheck
				PROPERTY
				ADDITIONAL_CLEAN_FILES
					"${CMAKE_CURRENT_BINARY_DIR}/CMakeFiles/${CPPCHECK_TARGET}_cppcheck.dir/codechecker_reports"
					"${CMAKE_CURRENT_BINARY_DIR}/CMakeFiles/${CPPCHECK_TARGET}_cppcheck.dir/reports"
				)
		endif()

		add_dependencies( cppcheck ${CPPCHECK_TARGET}_cppcheck )
	endif()
endfunction()
