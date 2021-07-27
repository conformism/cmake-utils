set( SANITIZER ""
	CACHE
	STRING
	"Compile with a sanitizer. Options are: ASAN, MSAN, MWOSAN, UBSAN, TSAN, LSAN, AUBSAN, CFISAN"
	)

#set( MSAN_LIBCXX ""
#	CACHE
#	STRING "Instrumented libc++ for memory sanitizer"
#	)

if( SANITIZER STREQUAL ASAN
OR  SANITIZER STREQUAL MSAN
OR  SANITIZER STREQUAL MWOSAN
OR  SANITIZER STREQUAL UBSAN
OR  SANITIZER STREQUAL TSAN
OR  SANITIZER STREQUAL LSAN
OR  SANITIZER STREQUAL AUBSAN
OR  SANITIZER STREQUAL CFISAN
	)
	message( STATUS "Enabled sanitizer: ${SANITIZER}" )
elseif( NOT SANITIZER )
else()
	message( ERROR " Invalid sanitizer: ${SANITIZER}" )
endif()

function( enable_sanitizers )
	set( OPTIONS )
	set( ONEVALUEARGS TARGET )
	set( MULTIVALUEARGS )
	cmake_parse_arguments( SANITIZERS
		"${OPTIONS}"
		"${ONEVALUEARGS}"
		"${MULTIVALUEARGS}"
		${ARGN}
		)

	if( SANITIZER )
		list( APPEND SANITIZERS_FLAGS
			-fno-omit-frame-pointer
			)
	endif()
	if( SANITIZER STREQUAL ASAN )
		list( APPEND SANITIZERS_FLAGS
			-fsanitize=address
			)
	elseif( SANITIZER STREQUAL MSAN )
		list( APPEND SANITIZERS_FLAGS
			-fsanitize=memory
			)
	elseif( SANITIZER STREQUAL MWOSAN )
		list( APPEND SANITIZERS_FLAGS
			-fsanitize=memory
			-fsanitize-memory-track-origins
			)
	elseif( SANITIZER STREQUAL UBSAN )
		list( APPEND SANITIZERS_FLAGS
			-fsanitize=undefined
			-fsanitize=nullability
			)
	elseif( SANITIZER STREQUAL TSAN )
		list( APPEND SANITIZERS_FLAGS
			-fsanitize=thread
			)
	elseif( SANITIZER STREQUAL LSAN )
		list( APPEND SANITIZERS_FLAGS
			-fsanitize=leak
			)
	elseif( SANITIZER STREQUAL AUBSAN )
		list( APPEND SANITIZERS_FLAGS
			-fsanitize=address
			-fsanitize=undefined
			-fsanitize=nullability
			)
	elseif( SANITIZER STREQUAL CFISAN )
		list( APPEND SANITIZERS_FLAGS
			-fsanitize=cfi
			)
	endif()

	if( CMAKE_CXX_COMPILER_ID MATCHES GNU OR CMAKE_CXX_COMPILER_ID MATCHES Clang )
		target_compile_options( ${SANITIZERS_TARGET}
			PRIVATE
			${SANITIZERS_FLAGS}
			)

		target_link_libraries( ${SANITIZERS_TARGET}
			${SANITIZERS_FLAGS}
			)
	endif()
endfunction()
