find_program( LIZARD NAMES lizard )
if( LIZARD )
	message( STATUS "Found Lizard: ${LIZARD}" )
	add_custom_target( lizard )
else()
	message( STATUS "Not found Lizard: lizard targets disabled" )
endif()

################################################################################
# lizard(
#        [TARGET target]
#        [ADDITIONAL_FILES file1 [file2] ...]
#        [ARGS arg1 [arg2] ...]
#        )
# [TARGET]
#       Target to analyse. Every sourcce file will be analysed.
# [ADDITIONAL_FILES]
#       Specify other files to analyse, headers for instance.
# [ARGS]
#       Specify command line arguments.
################################################################################
function( lizard )
	set( OPTIONS )
	set( ONEVALUEARGS TARGET )
	set( MULTIVALUEARGS ADDITIONAL_FILES ARGS )
	cmake_parse_arguments( LIZARD
		"${OPTIONS}"
		"${ONEVALUEARGS}"
		"${MULTIVALUEARGS}"
		${ARGN}
		)

	if( STATIC_ERROR )
		set( LIZARD_ERROR 1 )
	else()
		set( LIZARD_ERROR 0 )
	endif()
	if( LIZARD_TARGET )
		get_target_property( LIZARD_SRC ${LIZARD_TARGET} SOURCES )
	else()
		message( FATAL_ERROR "Specify a target!" )
	endif()
	foreach( ARG ${LIZARD_ARGS} )
		list( APPEND ALL_ARGS ${ARG} )
	endforeach()

	if( LIZARD )
		add_custom_target( ${LIZARD_TARGET}_lizard
			SOURCES ${LIZARD_SRC} ${LIZARD_ADDITIONAL_FILES}
			COMMENT "Lizard"
			COMMAND ${LIZARD}
				${ALL_ARGS}
				${LIZARD_SRC}
				${LIZARD_ADDITIONAL_FILES}
				|| exit ${LIZARD_ERROR}
			)
		add_dependencies( lizard ${LIZARD_TARGET}_lizard )
	endif()
endfunction()
