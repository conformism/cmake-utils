find_program( IWYU NAMES include-what-you-use iwyu )
if( IWYU )
	message( STATUS "Found IWYU: ${IWYU}" )
else()
	message( STATUS "Not found IWYU: iwyu targets disabled" )
endif()
find_program( IWYU_TOOL NAMES iwyu_tool.py iwyu_tool )
if( IWYU_TOOL )
	message( STATUS "Found iwyu_tool: ${IWYU_TOOL}" )
else()
	message( STATUS "Not found iwyu_tool: iwyu targets disabled" )
endif()

if( IWYU AND IWYU_TOOL )
	add_custom_target( iwyu )
endif()

mark_as_advanced( IWYU )
mark_as_advanced( IWYU_TOOL )

################################################################################
# iwyu(
#      [TARGET target]
#      [ADDITIONAL_FILES file1 [file2] ...]
#      [ARGS arg1 [arg2] ...]
#      )
# [TARGET]
#       Target to analyse. Every source file will be analysed.
# [ADDITIONAL_FILES]
#       Specify other files to analyse, headers for instance.
# [ARGS]
#       Specify command line arguments.
################################################################################
function( iwyu )
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
		message( FATAL_ERROR "Specify a target!" )
	endif()

	if( IWYU AND IWYU_TOOL )
		add_custom_target( ${IWYU_TARGET}_iwyu
			SOURCES ${IWYU_SRC} ${IWYU_ADDITIONAL_FILES}
#			COMMENT "Include What You Use"
			)

		list( APPEND IWYU_SRC ${IWYU_ADDITIONAL_FILES} )
		foreach( SRC ${IWYU_SRC} )
			add_custom_command(
				TARGET ${IWYU_TARGET}_iwyu
				PRE_BUILD
				COMMAND ${IWYU_TOOL}
					${SRC}
					${IWYU_ARGS}
					|| exit ${IWYU_ERROR}
				COMMENT "IWYU ${SRC}"
				)
		endforeach()
		add_dependencies( iwyu ${IWYU_TARGET}_iwyu )
	endif()
endfunction()
