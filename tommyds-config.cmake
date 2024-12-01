# FindTommyDS.cmake

# Locate the TommyDS library
# This module defines the following variables:
#   TOMMYDS_FOUND - set to 1 if the library is found
#   TOMMYDS_INCLUDE_DIRS - the directory containing the header files
#   TOMMYDS_LIBRARIES - the libraries to link against

find_path(TOMMYDS_INCLUDE_DIR
    NAMES tommyds/tommy.h
)

find_library(TOMMYDS_LIBRARY
    NAMES tommyds
)

# Handle the QUIETLY and REQUIRED arguments and set TOMMYDS_FOUND to TRUE if all components are found
include(FindPackageHandleStandardArgs)

find_package_handle_standard_args(tommyds
    REQUIRED_VARS TOMMYDS_INCLUDE_DIR TOMMYDS_LIBRARY)

if(tommyds_FOUND)
    set(TOMMYDS_LIBRARIES ${TOMMYDS_LIBRARY})
    set(TOMMYDS_INCLUDE_DIRS ${TOMMYDS_INCLUDE_DIR})

    # Define the TommyDS::tommyds library target if not already defined
    if(NOT TARGET tommyds::tommyds)
        add_library(tommyds::tommyds UNKNOWN IMPORTED)
        set_target_properties(tommyds::tommyds
            PROPERTIES IMPORTED_LOCATION ${TOMMYDS_LIBRARY}
            INTERFACE_INCLUDE_DIRECTORIES ${TOMMYDS_INCLUDE_DIR}
    )
    endif()
endif()

mark_as_advanced(TOMMYDS_INCLUDE_DIR TOMMYDS_LIBRARY)
