find_program( IWYU NAMES iwyu )
if( IWYU )
	message( STATUS "Found IWYU: ${IWYU}" )
	add_custom_target( iwyu )
else()
	message( STATUS "Not found IWYU: iwyu targets disabled" )
endif()

################################################################################
# static_analysis_iwyu(
#                      [TARGET target]
#                      [ADDITIONAL_FILES file1 [file2] ...]
#                      [ARGS arg1 [arg2] ...]
#                      )
# [TARGET]
#       Target to analyse. Every sourcce file will be analysed.
# [ADDITIONAL_FILES]
#       Specify other files to analyse, headers for instance.
# [ARGS]
#       Specify command line arguments.
################################################################################
function( static_analysis_iwyu )
	set( OPTIONS )
	set( ONEVALUEARGS TARGET )
	set( MULTIVALUEARGS ADDITIONAL_FILES ARGS )
	cmake_parse_arguments( IWYU
		"${OPTIONS}"
		"${ONEVALUEARGS}"
		"${MULTIVALUEARGS}"
		${ARGN}
		)

	if( STATIC_ERROR )
		set( IWYU_ERROR 1 )
	else()
		set( IWYU_ERROR 0 )
	endif()
	if( IWYU_TARGET )
		get_target_property( IWYU_SRC ${IWYU_TARGET} SOURCES )
	else()
		message( FATAL_ERROR "static_analysis_iwyu() : Specify a target!" )
	endif()
	foreach( ARG ${IWYU_ARGS} )
		list( APPEND ALL_ARGS ${ARG} )
	endforeach()

	if( IWYU )
		add_custom_target( ${IWYU_TARGET}_iwyu
			SOURCES ${IWYU_SRC} ${IWYU_ADDITIONAL_FILES}
#			COMMENT "Include What You Use"
			)

		list( APPEND IWYU_SRC ${IWYU_ADDITIONAL_FILES} )
		foreach( SRC ${IWYU_SRC} )
			add_custom_command(
				TARGET ${IWYU_TARGET}_iwyu
				PRE_BUILD
				COMMAND ${IWYU}
					${IWYU_ARGS}
					${SRC}
					|| exit ${IWYU_ERROR}
				COMMENT "IWYU ${SRC}"
				)
		endforeach()
		add_dependencies( iwyu ${IWYU_TARGET}_iwyu )
	endif()
endfunction()
