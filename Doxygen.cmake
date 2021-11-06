find_program( DOXYGEN NAMES doxygen )
find_program( DIA NAMES dia )
find_program( DOT NAMES dot )
find_program( PLANTUML NAMES plantuml )
find_program( GENHTML NAMES genhtml )

set( COVERXYGEN_COMMAND
	${Python3_EXECUTABLE} -m coverxygen
	)

find_package( Python3 )
execute_process(
	COMMAND ${Python3_EXECUTABLE}
		-m coverxygen
		--version
	RESULT_VARIABLE COVERXYGEN
	OUTPUT_VARIABLE COVERXYGEN_VERSION
	ERROR_QUIET
	)

if( DOXYGEN_MCSS )
	include( FetchContent )

	message( STATUS "Fetching m.css" )
	FetchContent_Declare( MCSS
		GIT_REPOSITORY "https://github.com/mosra/m.css"
		GIT_TAG ${MCSS_VERSION}
		)

	FetchContent_Populate( MCSS )
endif()

if( NOT COVERXYGEN )
	set( COVERXYGEN ON )
	string( REPLACE "\n" "" COVERXYGEN_VERSION ${COVERXYGEN_VERSION} )
	message( STATUS "Found Coverxygen: ${COVERXYGEN_VERSION}" )
else()
	set( COVERXYGEN OFF )
	message( STATUS "Not found Coverxygen: dox_cov targets disabled" ) 
endif()

if( DOXYGEN )
	message( STATUS "Found doxygen: ${DOXYGEN}" )
	add_custom_target( dox )
else()
	message( STATUS "Not found doxygen: dox targets disabled" )
endif()

################################################################################
# doxygen(
#         [TARGET target]
#         [DOXYFILE file]
#         [MCSS_CONF file]
#         [TARGETS_TO_DOC target1 [target2] ...]
#         [ADDITIONAL_FILES file1 [file2] ...]
#         [COVERXYGEN_ARGS arg1 [arg2] ...]
#         )
# [TARGET]
#       Target name, better add '_dox' suffix.
# [TARGETS_TO_DOC]
#       Targets to run Doxygen on.
# [ADDITIONAL_FILES]
#       Specify other files to analyse, headers for instance.
# [DOXYFILE]
#       Doxyfile path. Following values are required:
#       CLANG_DATABASE_PATH = @DOXYGEN_CLANG_DATABASE_PATH@
#       GENERATE_HTML = @DOXYGEN_GENERATE_HTML@
#       GENERATE_XML = @DOXYGEN_GENERATE_XML@
#       HTML_OUTPUT = @DOXYGEN_HTML_OUTPUT@
#       OUTPUT_DIRECTORY = @DOXYGEN_OUTPUT_DIRECTORY@
#       XML_OUTPUT = @DOXYGEN_XML_OUTPUT@
#       XML_PROGRAMLISTING = @DOXYGEN_XML_PROGRAMLISTING@
# [MCSS_CONF]
#       M.CSS configuration file path. Following values are required:
#       DOXYFILE = @MCSS_DOXYFILE@
#       @MCSS_DOXYGEN_COVERAGE_INDEX@ may be used in LINKS_NAVBAR1 or
#       LINKS_NAVBAR1 to add a link to Doxygen coverage Lcov report.
# [COVERXYGEN_ARGS]
#       Specify Coverxygen command line arguments. '--src-dir' is required.
################################################################################
function( doxygen )
	set( OPTIONS EXCLUDE_FROM_ALL )
	set( ONEVALUEARGS TARGET DOXYFILE MCSS_CONF )
	set( MULTIVALUEARGS TARGETS_TO_DOC ADDITIONAL_FILES COVERXYGEN_ARGS )
	cmake_parse_arguments( DOX
		"${OPTIONS}"
		"${ONEVALUEARGS}"
		"${MULTIVALUEARGS}"
		${ARGN}
		)

	if( DOXYGEN )
		if( DOX_TARGET )
			set( TARGET_NAME ${DOX_TARGET} )
		else()
			list( LENGTH DOX_TARGETS_TO_DOC N_TARGETS )
			if( ${N_TARGETS} EQUAL 1 )
				set( TARGET_NAME ${DOX_TARGETS_TO_DOC}_dox )
			else()
				message( FATAL_ERROR "doxygen() : Specify a target name!" )
			endif()
		endif()

		set( TARGET_DIR
			"${CMAKE_CURRENT_BINARY_DIR}/CMakeFiles/${TARGET_NAME}.dir"
			)
		set( TARGET_COV_DIR
			"${CMAKE_CURRENT_BINARY_DIR}/CMakeFiles/${TARGET_NAME}_cov.dir"
			)

		foreach( TARGET ${DOX_TARGETS_TO_DOC} )
			get_target_property( TARGET_SRC ${TARGET} SOURCES )
			list( APPEND SRC ${TARGET_SRC} )
		endforeach()
		list( APPEND SRC ${DOX_ADDITIONAL_FILES} )

		foreach( PATH ${SRC} )
			set( DOXYGEN_INPUT "${DOXYGEN_INPUT} \\\n\t${PATH}" )
		endforeach()
		
		set( DOXYGEN_OUTPUT_DIRECTORY "${TARGET_DIR}" )
		set( DOXYGEN_GENERATE_XML YES )
		set( DOXYGEN_HTML_OUTPUT html )
		set( DOXYGEN_XML_OUTPUT xml )

		if( DOXYGEN_MCSS )
			set( DOXYGEN_GENERATE_HTML NO )
			set( DOXYGEN_XML_PROGRAMLISTING NO )
			set( MCSS_DOXYFILE "${TARGET_DIR}/Doxyfile" )
			set( MCSS_DOXYGEN_COVERAGE_INDEX "../../${TARGET_NAME}_cov.dir/html/index.html" )
			configure_file(
				"${DOX_MCSS_CONF}"
				"${TARGET_DIR}/mcss.conf.py"
				@ONLY
				)
		else()
			set( DOXYGEN_GENERATE_HTML YES )
		endif()

		configure_file(
			"${DOX_DOXYFILE}"
			"${TARGET_DIR}/Doxyfile"
			@ONLY
			)

		if( DOXYGEN_MCSS )
			add_custom_command(
				OUTPUT
					"${TARGET_DIR}/html/index.html"
					"${TARGET_DIR}/xml/index.xml"
				DEPENDS
					${SRC}
					"${TARGET_DIR}/Doxyfile"
					"${TARGET_DIR}/mcss.conf.py"
				COMMAND "${FETCHCONTENT_BASE_DIR}/mcss-src/documentation/doxygen.py"
					"${TARGET_DIR}/mcss.conf.py"
				COMMENT "Generate Doxygen m.css documentation"
				)
			add_custom_target( ${TARGET_NAME}
				DEPENDS "${TARGET_DIR}/html/index.html"
				)
			add_custom_command( TARGET ${TARGET_NAME}
				POST_BUILD
				COMMENT "${TARGET_DIR}/html/index.html"
				)

			if( COVERXYGEN AND GENHTML )
				add_custom_target( ${TARGET_NAME}_cov
					DEPENDS "${TARGET_DIR}/xml/index.xml"
					COMMAND python3 -m coverxygen
						--xml-dir "${TARGET_DIR}/xml"
						--format lcov
						--output "${TARGET_COV_DIR}/coverage.info"
						${DOX_COVERXYGEN_ARGS}
					COMMAND genhtml
						-q
						"${TARGET_COV_DIR}/coverage.info"
						-o "${TARGET_COV_DIR}/html"
						--no-branch-coverage
						--no-function-coverage
					COMMAND python3 -m coverxygen
						--xml-dir "${TARGET_DIR}/xml"
						--format summary
						--output -
						${DOX_COVERXYGEN_ARGS}
					COMMENT "Perform documentation coverage, generate lcov report"
					)
				add_custom_command( TARGET ${TARGET_NAME}_cov
					POST_BUILD
					COMMENT "${TARGET_COV_DIR}/html/index.html"
					)
				add_dependencies( ${TARGET_NAME} ${TARGET_NAME}_cov )
			endif()
		else()
			add_custom_command(
				OUTPUT
					"${TARGET_DIR}/html/index.html"
					"${TARGET_DIR}/xml/index.xml"
				DEPENDS ${SRC} "${TARGET_DIR}/Doxyfile"
				COMMAND ${DOXYGEN}
					"${TARGET_DIR}/Doxyfile"
				COMMENT "Generate Doxygen documentation"
				)
			add_custom_target( ${TARGET_NAME}
				DEPENDS "${TARGET_DIR}/html/index.html"
				)
			add_custom_command( TARGET ${TARGET_NAME}
				POST_BUILD
				COMMENT "${TARGET_DIR}/html/index.html"
				)

			if( COVERXYGEN AND GENHTML )
				add_custom_target( ${TARGET_NAME}_cov
					DEPENDS "${TARGET_DIR}/xml/index.xml"
					COMMAND python3 -m coverxygen
						--xml-dir "${TARGET_DIR}/xml"
						--format lcov
						--output "${TARGET_COV_DIR}/coverage.info"
						${DOX_COVERXYGEN_ARGS}
					COMMAND genhtml
						-q
						"${TARGET_COV_DIR}/coverage.info"
						-o "${TARGET_COV_DIR}/html"
						--no-branch-coverage
						--no-function-coverage
					COMMAND python3 -m coverxygen
						--xml-dir "${TARGET_DIR}/xml"
						--format summary
						--output -
						${DOX_COVERXYGEN_ARGS}
					COMMENT "Perform documentation coverage, generate lcov report"
					)
				add_custom_command( TARGET ${TARGET_NAME}_cov
					POST_BUILD
					COMMENT "${TARGET_COV_DIR}/html/index.html"
					)
				add_dependencies( ${TARGET_NAME} ${TARGET_NAME}_cov )
			endif()

		endif()

		if( NOT DOX_EXCLUDE_FROM_ALL )
			add_dependencies( dox ${TARGET_NAME} )
		endif()
	endif()
endfunction()
