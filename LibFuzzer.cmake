if( LIBFUZZER )
	if( NOT CMAKE_CXX_COMPILER_ID MATCHES Clang )
		message( FATAL_ERROR "LibFuzzer is a LLVM feature: use Clang!" )
	endif()
	add_custom_target( fuzz )
endif()

################################################################################
# add_libfuzzer_target(
#                      [TARGET tgt]
#                      [SOURCE src]
#                      [TARGET_TO_FUZZ tgt]
#                      [EXCLUDE_FROM_ALL]
#                      [ARGS arg1 [arg2] ...]
#                      )
# [TARGET]
#       Fuzzing target name.
# [SOURCE]
#       Source file containing the libfuzzer entry point.
# [TARGET_TO_FUZZ]
#       Target tested by the fuzzing target.
# [EXCLUDE_FROM_ALL]
#       Exclude the fuzzing target from global call to 'fuzz' target.
# [ARGS]
#       Arguments to pass to the fuzzing target run.
################################################################################
function( add_libfuzzer_target )
	set( OPTIONS EXCLUDE_FROM_ALL )
	set( ONEVALUEARGS SOURCE TARGET TARGET_TO_FUZZ ) #GROUP
	set( MULTIVALUEARGS ARGS )
	cmake_parse_arguments( LIBFUZZER
		"${OPTIONS}"
		"${ONEVALUEARGS}"
		"${MULTIVALUEARGS}"
		${ARGN}
		)

# Name : ${TARGET_TO_FUZZ}_fuzz_${SRC_PATH_FROM_TEST/FUZZ-.CPP}
	if( LIBFUZZER AND CMAKE_CXX_COMPILER_ID MATCHES Clang )
		set( TARGET_DIR
			"${CMAKE_CURRENT_BINARY_DIR}/CMakeFiles/${LIBFUZZER_TARGET}_run.dir"
			)

		add_executable( ${LIBFUZZER_TARGET} EXCLUDE_FROM_ALL )

		target_sources( ${LIBFUZZER_TARGET}
			PRIVATE
			${LIBFUZZER_SOURCE}
			)

		target_link_libraries( ${LIBFUZZER_TARGET}
			${LIBFUZZER_TARGET_TO_FUZZ}
			-fsanitize=fuzzer
			)

		target_compile_options( ${LIBFUZZER_TARGET}
			PRIVATE
			-fsanitize=fuzzer
			-g
			)

		target_compile_options( ${LIBFUZZER_TARGET_TO_FUZZ}
			PRIVATE
			-fsanitize=fuzzer
			-g
			)

		add_custom_target( ${LIBFUZZER_TARGET}_run
			COMMENT "Running fuzzer target ${LIBFUZZER_TARGET}"
			)

		if( SANITIZER )
			enable_sanitizers(
				TARGET ${LIBFUZZER_TARGET}
				)
		endif()

		if( CODECHECKER_REPORT AND CODECHECKER AND REPORT_CONVERTER AND SANITIZER )
			string( TOLOWER
				${SANITIZER}
				SANITIZER_STR
				)

			set( CODECHECKER_ARGS
#				2> >( tee "${TARGET_DIR}/reports/${LIBFUZZER_TARGET}_${SANITIZER_STR}" )
				2>&1 | tee "${TARGET_DIR}/reports/${LIBFUZZER_TARGET}_${SANITIZER_STR}"
				)

			add_custom_command(
				TARGET ${LIBFUZZER_TARGET}_run
				POST_BUILD
				COMMAND ${CMAKE_COMMAND} -E make_directory
					"${TARGET_DIR}/reports"
				)
		endif()

		add_custom_command(
			TARGET ${LIBFUZZER_TARGET}_run
			COMMAND ${CMAKE_COMMAND} -E make_directory
				"${TARGET_DIR}/crash"
			COMMAND
				$<TARGET_FILE:${LIBFUZZER_TARGET}>
				-artifact_prefix="${TARGET_DIR}/crash/"
				${LIBFUZZER_ARGS}
				${CODECHECKER_ARGS}
				|| ${CMAKE_COMMAND} -E true
			)
		add_custom_command(
			TARGET ${LIBFUZZER_TARGET}_run
			COMMENT "${TARGET_DIR}/crash"
			)

		if( NOT EXCLUDE_FROM_ALL )
			add_dependencies( fuzz ${LIBFUZZER_TARGET}_run )
		endif()

		if( CODECHECKER_REPORT AND CODECHECKER AND REPORT_CONVERTER AND SANITIZER )
			add_custom_command(
				TARGET ${LIBFUZZER_TARGET}_run
				POST_BUILD
				COMMAND ${REPORT_CONVERTER}
					-t ${SANITIZER_STR}
					-o "${TARGET_DIR}/codechecker_reports"
					"${TARGET_DIR}/reports/${LIBFUZZER_TARGET}_${SANITIZER_STR}"
				COMMENT "CodeChecker ${SANITIZER} fuzzing report export"
				)
		endif()
	endif()
endfunction()
