# Script mode to remove '.gcda' files.
# During this step, go in each directory passed as argument and call the second
# step that list and remove matching files.
################################################################################
if( CMAKE_SCRIPT_MODE_FILE AND CLEAN_GCDA )
	set( ARG_I 0 )
	set( STARTED OFF )
	message( STATUS "Cleaning .gcda files" )

	while( ARG_I LESS ${CMAKE_ARGC} )
		if( STARTED )
			execute_process(
				COMMAND ${CMAKE_COMMAND} -E
					chdir "${CMAKE_ARGV${ARG_I}}"
					${CMAKE_COMMAND}
					-DCLEAN_GCDA_1=ON
					-P "${CMAKE_CURRENT_LIST_FILE}"
				)
		endif()

		if( "${CMAKE_ARGV${ARG_I}}" STREQUAL -- )
			set( STARTED ON )
		endif()

		math( EXPR ARG_I "${ARG_I}+1" )
	endwhile()

	return()
elseif( CMAKE_SCRIPT_MODE_FILE AND CLEAN_GCDA_1 )
	file( GLOB_RECURSE ALL_GCDA_FILES "*.gcda" )

	execute_process(
		OUTPUT_QUIET
		ERROR_QUIET
		COMMAND ${CMAKE_COMMAND} -E
			rm -f ${ALL_GCDA_FILES} ""
		)

	return()
endif()

if( COVERAGE OR CMAKE_BUILD_TYPE MATCHES Coverage )
	if( CMAKE_CXX_COMPILER_ID MATCHES GNU )
		find_program( GCOV NAMES gcov )
		if( GCOV )
			message( STATUS "Found gcov: ${GCOV}" )
		else()
			message( FATAL_ERROR "Not found gcov: install it" )
		endif()

		if( SONAR )
			find_program( GCOVR NAMES gcovr )
			if( GCOVR )
				message( STATUS "Found gcovr: ${GCOVR}" )
			else()
				message( FATAL_ERROR "Not found gcovr: install it" )
			endif()
		else()
			find_program( LCOV NAMES lcov )
			if( LCOV )
				message( STATUS "Found lcov: ${LCOV}" )
			else()
				message( FATAL_ERROR "Not found lcov: install it" )
			endif()

			find_program( GENHTML NAMES genhtml )
			if( GENHTML )
				message( STATUS "Found genhtml: ${GENHTML}" )
			else()
				message( FATAL_ERROR "Not found genhtml: install it" )
			endif()
		endif()

	elseif( CMAKE_CXX_COMPILER_ID MATCHES Clang )

		if( SONAR )
			message( FATAL_ERROR "Sonarqube support for llvm-cov reports seemed to be broken and is not implemented here, use GCC instead" )
		endif()

		find_program( LLVM_COV NAMES llvm-cov )
		if( LLVM_COV )
			message( STATUS "Found llvm-cov: ${LLVM_COV}" )
		else()
			message( FATAL_ERROR "Not found llvm-cov: install it" )
		endif()

		find_program( LLVM_PROFDATA NAMES llvm-profdata )
		if( LLVM_PROFDATA )
			message( STATUS "Found llvm-profdata: ${LLVM_PROFDATA}" )
		else()
			message( FATAL_ERROR "Not found llvm-profdata: install it" )
		endif()
	endif()

	if( COVERAGE_GLOBAL_ONLY AND NOT SONAR )
		add_custom_target( coverage_all )
	endif()

	find_package( Catch2 3.0.0 REQUIRED )
	if( Catch2_FOUND )
		message( STATUS "Found Catch2: ${Catch2_VERSION}" )
	endif()

else()

	find_package( Catch2 3.0.0 QUIET )
	if( Catch2_FOUND )
		message( STATUS "Found Catch2: ${Catch2_VERSION}" )
	else()
		message( STATUS "Not found Catch2 >= 3.0.0: unittest targets disabled" )
	endif()
endif()

unset( COVERAGE_TARGETS CACHE )
set( CURRENT_FILE ${CMAKE_CURRENT_LIST_FILE} )

mark_as_advanced( GCOV )
mark_as_advanced( GCOVR )
mark_as_advanced( LCOV )
mark_as_advanced( GENHTML )
mark_as_advanced( LLVM_COV )
mark_as_advanced( LLVM_PROFDATA )
mark_as_advanced( Catch2_DIR )

################################################################################
# coverage(
#          [TARGET_TO_RUN target]
#          [TARGETS_TO_COVER target1 [target2] ...]
#          [EXCLUDE_FROM_ALL]
#          [ARGS_GCOVR arg1 [arg2] ...]
#          )
# [TARGET_TO_RUN]
#       Target to run, typically a unittest executable.
# [TARGETS_TO_COVER]
#       Targets to produce coverage reports on, typically libraries tested by
#       the unittest executable.
# [EXCLUDE_FROM_ALL]
#       Exclude the coverage target from global reports produced by 'coverage'
#       target.
# [ARGS_GCOVR]
#       Arguments to pass to gcovr (used for sonarqube reports), especially
#       useful to specify source coverage filters ('-e' and '-f').
# [ARGS_RUN]
#       Arguments to pass to the unittest executable, especially useful to
#       filter the executed tests during a development phase.
################################################################################
function( coverage )
	set( OPTIONS EXCLUDE_FROM_ALL )
	set( ONEVALUEARGS TARGET_TO_RUN )
	set( MULTIVALUEARGS TARGETS_TO_COVER ARGS_GCOVR ARGS_RUN )
	cmake_parse_arguments( COVERAGE
		"${OPTIONS}"
		"${ONEVALUEARGS}"
		"${MULTIVALUEARGS}"
		${ARGN}
		)

	if( COVERAGE OR CMAKE_BUILD_TYPE MATCHES Coverage )
		foreach( TARGET ${COVERAGE_TARGETS_TO_COVER} ${TARGET_TO_RUN} )
			string( CONCAT TARGET_NAME
				${TARGET_NAME}
				${TARGET}_
				)

			if( CMAKE_CXX_COMPILER_ID MATCHES GNU AND NOT SONAR )
				list( APPEND TARGETS_TO_COVER_DIRS_D
					-d
					$<TARGET_PROPERTY:${TARGET},BINARY_DIR>/CMakeFiles/${TARGET}.dir
					)
				list( APPEND TARGETS_TO_COVER_DIRS
					$<TARGET_PROPERTY:${TARGET},BINARY_DIR>/CMakeFiles/${TARGET}.dir
					)
			elseif( CMAKE_CXX_COMPILER_ID MATCHES GNU AND SONAR )
				list( APPEND TARGETS_TO_COVER_DIRS
					$<TARGET_PROPERTY:${TARGET},BINARY_DIR>/CMakeFiles/${TARGET}.dir
					)
			elseif( CMAKE_CXX_COMPILER_ID MATCHES Clang )
				list( APPEND TARGETS_TO_COVER_OBJS
					-object=$<TARGET_FILE:${TARGET}>
					)
				get_target_property( TARGET_TYPE ${TARGET} TYPE )
				if( TARGET_TYPE MATCHES STATIC_LIBRARY )
					message( WARNING "${TARGET} is a static library, coverage won't work for this target with llvm-cov" )
				endif()
			endif()

			target_compile_options( ${TARGET}
				PRIVATE
				-O0
				$<$<CXX_COMPILER_ID:GNU>:--coverage>
				$<$<CXX_COMPILER_ID:Clang>:-fprofile-instr-generate>
				$<$<CXX_COMPILER_ID:Clang>:-fcoverage-mapping>
				)
			target_link_libraries( ${TARGET}
				$<$<CXX_COMPILER_ID:GNU>:-lgcov>
				)
			target_link_options( ${TARGET}
				PRIVATE
				$<$<CXX_COMPILER_ID:Clang>:-fprofile-instr-generate>
				)
		endforeach()

		string( CONCAT TARGET_NAME
			${TARGET_NAME}
			coverage
			)
		set( TARGET_DIR
			"${CMAKE_CURRENT_BINARY_DIR}/CMakeFiles/${TARGET_NAME}.dir"
			)
		if( NOT COVERAGE_EXCLUDE_FROM_ALL )
			if( COVERAGE_GLOBAL_ONLY AND NOT SONAR )
				set( SUFFIX "_" )
			endif()
			set( COVERAGE_TARGETS
				${COVERAGE_TARGETS}
				${TARGET_NAME}${SUFFIX}
				CACHE INTERNAL ""
				)
		endif()

		if( COVERAGE_ERROR )
			set( COVERAGE_ERROR_STATUS 1 )
		else()
			set( COVERAGE_ERROR_STATUS 0 )
		endif()

		if( CMAKE_CXX_COMPILER_ID MATCHES GNU AND NOT SONAR )

			if( NOT COVERAGE_EXCLUDE_FROM_ALL )
				set( COVERAGE_TARGETS_DATA_FILES
					${COVERAGE_TARGETS_DATA_FILES}
					"${TARGET_DIR}/coverage.info"
					CACHE INTERNAL ""
					)
			endif()
			add_custom_command(
				OUTPUT "${TARGET_DIR}/coverage.info"
				DEPENDS
					${COVERAGE_TARGET_TO_RUN}
					${COVERAGE_TARGETS_TO_COVER}
				COMMAND ${CMAKE_COMMAND}
					-DCLEAN_GCDA=ON
					-P ${CURRENT_FILE}
					-- ${TARGETS_TO_COVER_DIRS}
				COMMAND
#					GCOV_PREFIX=${TARGET_DIR}
#					GCOV_PREFIX_STRIP=9
					$<TARGET_FILE:${COVERAGE_TARGET_TO_RUN}>
					${COVERAGE_ARGS_RUN}
					|| exit ${COVERAGE_ERROR_STATUS}
				COMMAND ${LCOV} -c
					${TARGETS_TO_COVER_DIRS_D}
#					-d ${TARGET_DIR}
					-o "${TARGET_DIR}/coverage.info"
					--rc lcov_branch_coverage=1
					-q
				COMMAND ${LCOV} -r
					"${TARGET_DIR}/coverage.info"
					'/usr/*'
					'/nix/store/*'
					-o "${TARGET_DIR}/coverage.info"
					--rc lcov_branch_coverage=1
					-q
				)
			add_custom_target( ${TARGET_NAME}
				DEPENDS "${TARGET_DIR}/coverage.info"
				COMMAND ${GENHTML}
					-q
					"${TARGET_DIR}/coverage.info"
					-o "${TARGET_DIR}/html"
					--branch-coverage
					--function-coverage
				COMMAND ${LCOV}
					-l "${TARGET_DIR}/coverage.info"
					--rc lcov_branch_coverage=1
				COMMENT "Run ${COVERAGE_TARGET_TO_RUN}, perform code coverage, generate lcov report"
				)
			add_custom_command( TARGET ${TARGET_NAME}
				POST_BUILD
				COMMENT "${TARGET_DIR}/html/index.html"
				)
			if( COVERAGE_GLOBAL_ONLY AND NOT COVERAGE_EXCLUDE_FROM_ALL )
				add_custom_target( ${TARGET_NAME}${SUFFIX}
					DEPENDS "${TARGET_DIR}/coverage.info"
					)
			endif()

			set_property(
				TARGET ${TARGET_NAME}
				PROPERTY
				ADDITIONAL_CLEAN_FILES
					"${TARGET_DIR}/html"
					"${TARGET_DIR}/coverage.info"
				)

		elseif( CMAKE_CXX_COMPILER_ID MATCHES GNU AND SONAR )

			get_target_property( TARGET_TO_RUN_DIR
				${COVERAGE_TARGET_TO_RUN}
				BINARY_DIR
				)
			set( TARGET_TO_RUN_DIR
				"${TARGET_TO_RUN_DIR}/CMakeFiles/${COVERAGE_TARGET_TO_RUN}.dir"
				)
			add_custom_command(
				OUTPUT
					"${TARGET_TO_RUN_DIR}/sonarqube_report_test.xml"
				DEPENDS
					${COVERAGE_TARGET_TO_RUN}
					${COVERAGE_TARGETS_TO_COVER}
				COMMAND ${CMAKE_COMMAND}
					-DCLEAN_GCDA=ON
					-P ${CURRENT_FILE}
					-- ${TARGETS_TO_COVER_DIRS}
				COMMAND
					$<TARGET_FILE:${COVERAGE_TARGET_TO_RUN}>
					${COVERAGE_ARGS_RUN}
					|| exit ${COVERAGE_ERROR_STATUS}
				COMMAND
					$<TARGET_FILE:${COVERAGE_TARGET_TO_RUN}>
					-r sonarqube
					-o "${TARGET_TO_RUN_DIR}/sonarqube_report_test.xml"
					${COVERAGE_ARGS_RUN}
					|| exit ${COVERAGE_ERROR_STATUS}
				)
			add_custom_command(
				DEPENDS
					"${TARGET_TO_RUN_DIR}/sonarqube_report_test.xml"
				OUTPUT
					"${TARGET_DIR}/sonarqube_report_coverage.xml"
				COMMAND ${GCOVR}
					--sonarqube "${TARGET_DIR}/sonarqube_report_coverage.xml"
					-r "${CMAKE_SOURCE_DIR}"
					-e "${CMAKE_SOURCE_DIR}/test"
					-e "${CMAKE_BINARY_DIR}"
					${TARGETS_TO_COVER_DIRS}
					${COVERAGE_ARGS_GCOVR}
					--exclude-unreachable-branches
					--exclude-throw-branches
					-s
				)
			add_custom_target( ${TARGET_NAME}
				DEPENDS
					"${TARGET_TO_RUN_DIR}/sonarqube_report_test.xml"
					"${TARGET_DIR}/sonarqube_report_coverage.xml"
				COMMENT "Run ${COVERAGE_TARGET_TO_RUN}, perform code coverage, generate sonarqube report"
				)
			if( COVERAGE_GCOVR_VERBOSE )
				add_custom_command( TARGET ${TARGET_NAME}
					POST_BUILD
					COMMAND ${GCOVR}
						-r "${CMAKE_SOURCE_DIR}"
						-e "${CMAKE_SOURCE_DIR}/test"
						-e "${CMAKE_BINARY_DIR}"
						${TARGETS_TO_COVER_DIRS}
						${COVERAGE_ARGS_GCOVR}
						--exclude-unreachable-branches
						--exclude-throw-branches
					)
			endif()
			add_custom_command( TARGET ${TARGET_NAME}
				POST_BUILD
				COMMENT	"${TARGET_TO_RUN_DIR}/sonarqube_report_test.xml"
				)
			add_custom_command( TARGET ${TARGET_NAME}
				POST_BUILD
				COMMENT "${TARGET_DIR}/sonarqube_report_coverage.xml"
				)

			set_property(
				TARGET ${TARGET_NAME}
				PROPERTY
				ADDITIONAL_CLEAN_FILES
					"${TARGET_TO_RUN_DIR}/sonarqube_report_test.xml"
					"${TARGET_DIR}/sonarqube_report_coverage.xml"
				)

		elseif( CMAKE_CXX_COMPILER_ID MATCHES Clang AND NOT SONAR )

			if( NOT COVERAGE_EXCLUDE_FROM_ALL )
				set( COVERAGE_TARGETS_DATA_FILES
					${COVERAGE_TARGETS_DATA_FILES}
					"${TARGET_DIR}/coverage.profdata"
					CACHE INTERNAL ""
					)
				set( COVERAGE_TARGETS_OBJ_FILES
					${COVERAGE_TARGETS_OBJ_FILES}
					${TARGETS_TO_COVER_OBJS}
					CACHE INTERNAL ""
					)
			endif()
			add_custom_command(
				OUTPUT "${TARGET_DIR}/coverage.profdata"
				DEPENDS
					${COVERAGE_TARGET_TO_RUN}
					${COVERAGE_TARGETS_TO_COVER}
				COMMAND
					LLVM_PROFILE_FILE=${TARGET_DIR}/coverage.profraw
					$<TARGET_FILE:${COVERAGE_TARGET_TO_RUN}>
					${COVERAGE_ARGS_RUN}
					|| exit ${COVERAGE_ERROR_STATUS}
				COMMAND ${LLVM_PROFDATA} merge
					-sparse "${TARGET_DIR}/coverage.profraw"
					-o "${TARGET_DIR}/coverage.profdata"
				)
			add_custom_target( ${TARGET_NAME}
				DEPENDS "${TARGET_DIR}/coverage.profdata"
				COMMAND ${LLVM_COV} report
					${TARGETS_TO_COVER_OBJS}
					-instr-profile="${TARGET_DIR}/coverage.profdata"
					-ignore-filename-regex='${CMAKE_SOURCE_DIR}/test/*'
				COMMAND ${LLVM_COV} show
					${TARGETS_TO_COVER_OBJS}
					-instr-profile="${TARGET_DIR}/coverage.profdata"
					-output-dir="${TARGET_DIR}/html"
					-show-line-counts
					-show-expansions
					-show-regions
					-format="html"
				COMMENT "Run ${COVERAGE_TARGET_TO_RUN}, perform code coverage, generate llvm-cov report"
				)
			add_custom_command( TARGET ${TARGET_NAME}
				POST_BUILD
				COMMENT "${TARGET_DIR}/html/index.html"
				)
			if( COVERAGE_GLOBAL_ONLY AND NOT COVERAGE_EXCLUDE_FROM_ALL )
				add_custom_target( ${TARGET_NAME}${SUFFIX}
					DEPENDS "${TARGET_DIR}/coverage.profdata"
					)
			endif()

			set_property(
				TARGET ${TARGET_NAME}
				PROPERTY
				ADDITIONAL_CLEAN_FILES
					"${TARGET_DIR}/html"
					"${TARGET_DIR}/coverage.profdata"
					"${TARGET_DIR}/coverage.profraw"
				)

		endif()
		if( COVERAGE_GLOBAL_ONLY AND NOT SONAR )
			add_dependencies( coverage_all ${TARGET_NAME} )
		endif()
	endif()
endfunction()

################################################################################
# coverage_global()
################################################################################
function( coverage_global )
	if( COVERAGE OR CMAKE_BUILD_TYPE MATCHES Coverage )
		set( COVERAGE_DIR
			"${CMAKE_BINARY_DIR}/CMakeFiles/coverage.dir"
			)

		if( CMAKE_CXX_COMPILER_ID MATCHES GNU AND NOT SONAR )

			foreach( FILE ${COVERAGE_TARGETS_DATA_FILES} )
				list( APPEND ARGS_TARGETS_DATA_FILES
					-a ${FILE}
					)
			endforeach()

			add_custom_target( coverage
				COMMAND ${LCOV}
					-q
					${ARGS_TARGETS_DATA_FILES}
					-o "${COVERAGE_DIR}/coverage.info"
					--rc lcov_branch_coverage=1
				COMMAND ${GENHTML}
					-q
					"${COVERAGE_DIR}/coverage.info"
					-o "${COVERAGE_DIR}/html"
					--branch-coverage
					--function-coverage
				COMMAND ${LCOV}
					-l "${COVERAGE_DIR}/coverage.info"
					--rc lcov_branch_coverage=1
				COMMENT "Merge coverage reports & generate global lcov report"
				)
			add_custom_command( TARGET coverage
				POST_BUILD
				COMMENT "${COVERAGE_DIR}/html/index.html"
				)
			add_dependencies( coverage ${COVERAGE_TARGETS} )

			set_property(
				TARGET coverage
				PROPERTY
				ADDITIONAL_CLEAN_FILES
					"${COVERAGE_DIR}/html"
					"${COVERAGE_DIR}/coverage.info"
				)

		elseif( CMAKE_CXX_COMPILER_ID MATCHES GNU AND SONAR )

			add_custom_target( coverage )
			add_dependencies( coverage ${COVERAGE_TARGETS} )

		elseif( CMAKE_CXX_COMPILER_ID MATCHES Clang AND NOT SONAR )

			foreach( FILE ${COVERAGE_TARGETS_DATA_FILES} )
				list( APPEND ARGS_TARGETS_DATA_FILES
					${FILE}
					)
			endforeach()

			add_custom_target( coverage
				COMMAND ${LLVM_PROFDATA} merge
					${COVERAGE_TARGETS_DATA_FILES}
					-o "${COVERAGE_DIR}/coverage.profdata"
				COMMAND ${LLVM_COV} report
					${COVERAGE_TARGETS_OBJ_FILES}
					-instr-profile="${COVERAGE_DIR}/coverage.profdata"
					-ignore-filename-regex='${CMAKE_SOURCE_DIR}/test/*'
				COMMAND ${LLVM_COV} show
					${COVERAGE_TARGETS_OBJ_FILES}
					-instr-profile="${COVERAGE_DIR}/coverage.profdata"
					-output-dir="${COVERAGE_DIR}/html"
					-show-line-counts
					-show-expansions
					-show-regions
					-format="html"
				COMMENT "Merge coverage reports & generate global llvm-cov report"
				)
			add_custom_command( TARGET coverage
				POST_BUILD
				COMMENT "${COVERAGE_DIR}/html/index.html"
				)
			add_dependencies( coverage ${COVERAGE_TARGETS} )

			set_property(
				TARGET coverage
				PROPERTY
				ADDITIONAL_CLEAN_FILES
					"${COVERAGE_DIR}/html"
					"${COVERAGE_DIR}/coverage.profdata"
				)

		endif()
	endif()
endfunction()
