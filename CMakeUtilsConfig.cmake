set( CMakeUtils_FOUND ON )

list( PREPEND CMAKE_MODULE_PATH
	"${CMAKE_CURRENT_LIST_DIR}/Modules"
	)

mark_as_advanced( CMakeUtils_DIR )
