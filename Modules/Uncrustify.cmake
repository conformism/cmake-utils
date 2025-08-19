find_program( UNCRUSTIFY NAMES uncrustify )
if( UNCRUSTIFY )
	set( CMakeUtils_Uncrustify_FOUND ON )
	message( STATUS "Found Uncrustify: ${UNCRUSTIFY}" )
	add_custom_target( uncrustify )
	add_custom_target( uncrustify_fix )
	if( UNCRUSTIFY_DIFF )
		find_program( DIFF NAMES diff )
		if( DIFF )
			message( STATUS "Found diff: ${DIFF}" )
		else()
			message( STATUS "Not found diff: uncrustify diff mode disabled" )
			set( UNCRUSTIFY_DIFF OFF )
		endif()
	endif()
else()
	set( CMakeUtils_Uncrustify_FOUND OFF )
	message( STATUS "Not found Uncrustify: uncrustify targets disabled" )
endif()

mark_as_advanced( UNCRUSTIFY )
mark_as_advanced( DIFF )

################################################################################
# uncrustify(
#            [TARGET target]
#            [ADDITIONAL_FILES file1 [file2] ...]
#            [ARGS arg1 [arg2] ...]
#            )
# [TARGET]
#       Target to analyse. Every source file will be analysed.
# [ADDITIONAL_FILES]
#       Specify other files to analyse, headers for instance.
# [ARGS]
#       Specify command line arguments.
################################################################################
function( uncrustify )
	set( OPTIONS )
	set( ONEVALUEARGS TARGET )
	set( MULTIVALUEARGS ADDITIONAL_FILES ARGS )
	cmake_parse_arguments( UNCRUSTIFY
		"${OPTIONS}"
		"${ONEVALUEARGS}"
		"${MULTIVALUEARGS}"
		${ARGN}
		)

	if( STATIC_ERROR )
		set( UNCRUSTIFY_ERROR 1 )
	else()
		set( UNCRUSTIFY_ERROR 0 )
	endif()
	if( UNCRUSTIFY_TARGET )
		get_target_property( UNCRUSTIFY_SRC ${UNCRUSTIFY_TARGET} SOURCES )
	else()
		message( FATAL_ERROR "Specify a target!" )
	endif()
	foreach( ARG ${UNCRUSTIFY_ARGS} )
		list( APPEND ALL_ARGS ${ARG} )
	endforeach()
	list( APPEND UNCRUSTIFY_SRC ${UNCRUSTIFY_ADDITIONAL_FILES} )

	if( UNCRUSTIFY )
		add_custom_target( ${UNCRUSTIFY_TARGET}_uncrustify
			SOURCES ${UNCRUSTIFY_SRC}
#			COMMENT "Uncrustify check"
			)

		foreach( SRC ${UNCRUSTIFY_SRC} )
			if( UNCRUSTIFY_DIFF )
				set( DIFF_ARGS --no-backup | ${DIFF} --color=always ${SRC} - )
			else()
				set( DIFF_ARGS --check )
			endif()

			add_custom_command(
				TARGET ${UNCRUSTIFY_TARGET}_uncrustify
				POST_BUILD
				COMMAND ${UNCRUSTIFY}
					${UNCRUSTIFY_ARGS}
					-f ${SRC}
					${DIFF_ARGS}
					|| exit ${UNCRUSTIFY_ERROR}
				COMMENT "Uncrustify check ${SRC}"
				)
		endforeach()
		add_dependencies( uncrustify ${UNCRUSTIFY_TARGET}_uncrustify )

		add_custom_target( ${UNCRUSTIFY_TARGET}_uncrustify_fix
			SOURCES ${UNCRUSTIFY_SRC}
#			COMMENT "Uncrustify fix"
			)

		foreach( SRC ${UNCRUSTIFY_SRC} )
			add_custom_command(
				TARGET ${UNCRUSTIFY_TARGET}_uncrustify_fix
				POST_BUILD
				COMMAND ${UNCRUSTIFY}
					--replace
					--no-backup
					${UNCRUSTIFY_ARGS}
					${SRC}
				COMMENT "Uncrustify fix ${SRC}"
				)
		endforeach()
		add_dependencies( uncrustify_fix ${UNCRUSTIFY_TARGET}_uncrustify_fix )
	endif()
endfunction()
