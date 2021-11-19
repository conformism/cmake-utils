find_program( CLANG_TIDY NAMES clang-tidy )
if( CLANG_TIDY )
	message( STATUS "Found Clang-Tidy: ${CLANG_TIDY}" )
	add_custom_target( tidy )
	add_custom_target( tidy_fix )
else()
	message( STATUS "Not found Clang-Tidy: tidy targets disabled" )
endif()

################################################################################
# clang_tidy(
#            [TARGET target]
#            [ADDITIONAL_FILES file1 [file2] ...]
#            [ARGS arg1 [arg2] ...]
#            )
# [TARGET]
#       Target to analyse. Every sourcce file will be analysed.
# [ADDITIONAL_FILES]
#       Specify other files to analyse, headers for instance.
# [ARGS]
#       Specify command line arguments.
################################################################################
function( clang_tidy )
	set( OPTIONS )
	set( ONEVALUEARGS TARGET )
	set( MULTIVALUEARGS ADDITIONAL_FILES ARGS )
	cmake_parse_arguments( TIDY
		"${OPTIONS}"
		"${ONEVALUEARGS}"
		"${MULTIVALUEARGS}"
		${ARGN}
		)

	if( STATIC_ERROR )
		set( TIDY_ERROR 1 )
	else()
		set( TIDY_ERROR 0 )
	endif()
	if( STATIC_WERROR )
		set( TIDY_WERROR -warnings-as-errors=* )
	else()
		set( TIDY_WERROR )
	endif()
	if( TIDY_TARGET )
		get_target_property( TIDY_SRC ${TIDY_TARGET} SOURCES )
	else()
		message( FATAL_ERROR "clang_tidy() : Specify a target!" )
	endif()
	foreach( ARG ${TIDY_ARGS} )
		list( APPEND ALL_ARGS ${ARG} )
	endforeach()
	list( APPEND TIDY_SRC ${TIDY_ADDITIONAL_FILES} )

	if( CLANG_TIDY )
		add_custom_target( ${TIDY_TARGET}_tidy
			SOURCES ${TIDY_SRC}
#			COMMENT "Clang-Tidy check"
			)

		foreach( SRC ${TIDY_SRC} )
			add_custom_command(
				TARGET ${TIDY_TARGET}_tidy
				PRE_BUILD
				COMMAND ${CLANG_TIDY}
					${TIDY_WERROR}
					${TIDY_ARGS}
					${SRC}
					|| exit ${TIDY_ERROR}
				COMMENT "Clang-Tidy check ${SRC}"
				)
		endforeach()
		add_dependencies( tidy ${TIDY_TARGET}_tidy )

		add_custom_target( ${TIDY_TARGET}_tidy_fix
			SOURCES ${TIDY_SRC}
#			COMMENT "Clang-Tidy fix"
			)

		foreach( SRC ${TIDY_SRC} )
			add_custom_command(
				TARGET ${TIDY_TARGET}_tidy_fix
				PRE_BUILD
				COMMAND ${CLANG_TIDY}
					-fix
					${TIDY_WERROR}
					${TIDY_ARGS}
					${SRC}
					|| exit ${TIDY_ERROR}
				COMMENT "Clang-Tidy fix ${SRC}"
				)
		endforeach()
		add_dependencies( tidy_fix ${TIDY_TARGET}_tidy_fix )
	endif()
endfunction()
