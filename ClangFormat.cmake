find_program( CLANG_FORMAT NAMES clang-format )
if( CLANG_FORMAT )
	message( STATUS "Found Clang-Format: ${CLANG_FORMAT}" )
	add_custom_target( format )
	add_custom_target( format_fix )
else()
	message( STATUS "Not found Clang-Format: format targets disabled" )
endif()

################################################################################
# static_analysis_format(
#                        [TARGET target]
#                        [ADDITIONAL_FILES file1 [file2] ...]
#                        [ARGS arg1 [arg2] ...]
#                        )
# [TARGET]
#       Target to analyse. Every sourcce file will be analysed.
# [ADDITIONAL_FILES]
#       Specify other files to analyse, headers for instance.
# [ARGS]
#       Specify command line arguments.
################################################################################
function( static_analysis_format )
	set( OPTIONS )
	set( ONEVALUEARGS TARGET )
	set( MULTIVALUEARGS ADDITIONAL_FILES ARGS )
	cmake_parse_arguments( FORMAT
		"${OPTIONS}"
		"${ONEVALUEARGS}"
		"${MULTIVALUEARGS}"
		${ARGN}
		)

	if( STATIC_ERROR )
		set( FORMAT_ERROR 1 )
	else()
		set( FORMAT_ERROR 0 )
	endif()
	if( STATIC_WERROR )
		set( FORMAT_WERROR -Werror )
	else()
		set( FORMAT_WERROR )
	endif()
	if( FORMAT_TARGET )
		get_target_property( FORMAT_SRC ${FORMAT_TARGET} SOURCES )
	else()
		message( ERROR " static_analysis_format() : Specify a target!" )
	endif()
	foreach( ARG ${FORMAT_ARGS} )
		list( APPEND ALL_ARGS ${ARG} )
	endforeach()
	list( APPEND FORMAT_SRC ${FORMAT_ADDITIONAL_FILES} )

	if( CLANG_FORMAT )
		add_custom_target( ${FORMAT_TARGET}_format
			SOURCES ${FORMAT_SRC}
#			COMMENT "Clang-Format check"
			)

		foreach( SRC ${FORMAT_SRC} )
			add_custom_command(
				TARGET ${FORMAT_TARGET}_format
				PRE_BUILD
				COMMAND ${CLANG_FORMAT}
					--dry-run
					${FORMAT_WERROR}
					${FORMAT_ARGS}
					${SRC}
					|| exit ${FORMAT_ERROR}
				COMMENT "Clang-Format check ${SRC}"
				)
		endforeach()
		add_dependencies( format ${FORMAT_TARGET}_format )

		add_custom_target( ${FORMAT_TARGET}_format_fix
			SOURCES ${FORMAT_SRC}
#			COMMENT "Clang-Format fix"
			)

		foreach( SRC ${FORMAT_SRC} )
			add_custom_command(
				TARGET ${FORMAT_TARGET}_format_fix
				PRE_BUILD
				COMMAND ${CLANG_FORMAT}
					-i
					${FORMAT_WERROR}
					${FORMAT_ARGS}
					${SRC}
					|| exit ${FORMAT_ERROR}
				COMMENT "Clang-Format fix ${SRC}"
				)
		endforeach()
		add_dependencies( format_fix ${FORMAT_TARGET}_format_fix )
	endif()
endfunction()
