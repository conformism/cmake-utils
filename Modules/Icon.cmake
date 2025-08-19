find_program( CAIROSVG NAMES cairosvg )
if( CAIROSVG )
	message( STATUS "Found Cairosvg: ${CAIROSVG}" )
else()
	message( STATUS "Not found Cairosvg: icon utils disabled" )
endif()

find_program( MAGICK NAMES magick convert )
if( MAGICK )
	message( STATUS "Found ImageMagick: ${MAGICK}" )
else()
	message( STATUS "Not found ImageMagick: icon utils disabled" )
endif()

if( CAIROSVG AND MAGICK )
	set( CMakeUtils_Icon_FOUND ON )
else()
	set( CMakeUtils_Icon_FOUND OFF )
endif()

mark_as_advanced( CAIROSVG )
mark_as_advanced( MAGICK )

################################################################################
# svg_to_png(name
#           [DESTINATION destination_dir]
#           [SOURCE source_dir]
#           [SIZE size]
#           [REGISTER_TO var]
#           )
# [DESTINATION]
#       Directory where output png file is created. Default is :
#       "${CMAKE_CURRENT_BINARY_DIR}".
# [SOURCE]
#       Directory where input svg file is located. Default is :
#       "${CMAKE_CURRENT_SOURCE_DIR}".
# [SIZE]
#       Desired output size in pixels. Both formats "<size>" and
#       "<width>x<height>" are accepted.
# [REGISTER_TO]
#       Append output png file to var. To the png file to be compiled, at least
#       one target must DEPENDS on its output file. Avoid making more than one
#       target DEPENDS on one output pdf file, instead create dependencies
#       between other dependent targets and the one that wraps the png file
#       compilation.
################################################################################
function( svg_to_png NAME )
	set( OPTIONS )
	set( ONEVALUEARGS DESTINATION SIZE SOURCE REGISTER_TO )
	set( MULTIVALUEARGS )
	cmake_parse_arguments( SVG2PNG
		"${OPTIONS}"
		"${ONEVALUEARGS}"
		"${MULTIVALUEARGS}"
		${ARGN}
		)

	if( CAIROSVG )
		if( NOT SVG2PNG_SOURCE )
			set( SVG2PNG_SOURCE "${CMAKE_CURRENT_SOURCE_DIR}" )
		endif()
		if( NOT SVG2PNG_DESTINATION )
			set( SVG2PNG_DESTINATION "${CMAKE_CURRENT_BINARY_DIR}" )
		endif()
		if( SVG2PNG_SIZE )
			if( SVG2PNG_SIZE MATCHES "^([0-9]+)x([0-9])")
				set( SVG2PNG_SIZE_W --output-width ${CMAKE_MATCH_1} )
				set( SVG2PNG_SIZE_H --output-height ${CMAKE_MATCH_2} )
			else()
				set( SVG2PNG_SIZE_W --output-width ${SVG2PNG_SIZE} )
				set( SVG2PNG_SIZE_H --output-height ${SVG2PNG_SIZE} )
			endif()
		endif()

		add_custom_command(
			OUTPUT "${SVG2PNG_DESTINATION}/${NAME}.${SVG2PNG_SIZE}.png"
			DEPENDS "${SVG2PNG_SOURCE}/${NAME}.svg"
			COMMAND ${CAIROSVG}
				"${SVG2PNG_SOURCE}/${NAME}.svg"
				-o "${SVG2PNG_DESTINATION}/${NAME}.${SVG2PNG_SIZE}.png"
				${SVG2PNG_SIZE_W}
				${SVG2PNG_SIZE_H}
			)

		if( SVG2PNG_REGISTER_TO )
			list( APPEND "${SVG2PNG_REGISTER_TO}"
				"${SVG2PNG_DESTINATION}/${NAME}.${SVG2PNG_SIZE}.png"
				)
			set( "${SVG2PNG_REGISTER_TO}"
				"${${SVG2PNG_REGISTER_TO}}"
				PARENT_SCOPE
				)
		endif()
	endif()
endfunction()

################################################################################
# png_to_ico(name
#           [DESTINATION destination_dir]
#           [INPUT file1 [file2] ...]
#           [REGISTER_TO var]
#           )
# [DESTINATION]
#       Directory where output ico file is created. Default is :
#       "${CMAKE_CURRENT_BINARY_DIR}".
# [INPUT]
#       Input png files to combine in an ico file, typically multiple sizes of
#       of the same image. Inclusion order seems to matter when using the file
#       as an icon.
# [REGISTER_TO]
#       Append output ico file to var. To the ico file to be compiled, at least
#       one target must DEPENDS on its output file. Avoid making more than one
#       target DEPENDS on one output pdf file, instead create dependencies
#       between other dependent targets and the one that wraps the ico file
#       compilation.
################################################################################
function( png_to_ico NAME )
	set( OPTIONS )
	set( ONEVALUEARGS DESTINATION REGISTER_TO )
	set( MULTIVALUEARGS INPUT )
	cmake_parse_arguments( PNG2ICO
		"${OPTIONS}"
		"${ONEVALUEARGS}"
		"${MULTIVALUEARGS}"
		${ARGN}
		)

	if( MAGICK )
		if( NOT PNG2ICO_INPUT )
			message( FATAL_ERROR "Specify inputs!" )
		endif()
		if( NOT PNG2ICO_DESTINATION )
			set( PNG2ICO_DESTINATION "${CMAKE_CURRENT_BINARY_DIR}" )
		endif()

		add_custom_command(
			OUTPUT "${PNG2ICO_DESTINATION}/${NAME}.ico"
			DEPENDS ${PNG2ICO_INPUT}
			COMMAND ${MAGICK}
				${PNG2ICO_INPUT}
				"${PNG2ICO_DESTINATION}/${NAME}.ico"
			)

		if( PNG2ICO_REGISTER_TO )
			list( APPEND "${PNG2ICO_REGISTER_TO}"
				"${PNG2ICO_DESTINATION}/${NAME}.ico"
				)
			set( "${PNG2ICO_REGISTER_TO}"
				"${${PNG2ICO_REGISTER_TO}}"
				PARENT_SCOPE
				)
		endif()
	endif()
endfunction()
