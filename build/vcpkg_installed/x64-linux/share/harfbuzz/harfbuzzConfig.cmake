# For old projects where the minimum CMake version is lower than 3.3.
cmake_policy(SET CMP0012 NEW)
cmake_policy(SET CMP0054 NEW)
cmake_policy(SET CMP0057 NEW)

include(CMakeFindDependencyMacro)

# Traditional find module variables (vcpkg polyfill)
set(HARFBUZZ_INCLUDE_DIR "${VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/include/harfbuzz" CACHE INTERNAL "")
set(HARFBUZZ_INCLUDE_DIRS "${HARFBUZZ_INCLUDE_DIR}")
set(HARFBUZZ_LIBRARY harfbuzz::harfbuzz CACHE INTERNAL "")
set(HARFBUZZ_LIBRARIES harfbuzz::harfbuzz)

if(TARGET harfbuzz)
    set(HARFBUZZ_FOUND TRUE)
    return()
endif()

add_library(harfbuzz UNKNOWN IMPORTED)
add_library(harfbuzz::harfbuzz ALIAS harfbuzz)

find_library(HARFBUZZ_LIBRARY_DEBUG NAMES harfbuzz PATHS "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/debug" PATH_SUFFIXES lib NO_DEFAULT_PATH)
find_library(HARFBUZZ_LIBRARY_RELEASE NAMES harfbuzz PATHS "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}" PATH_SUFFIXES lib NO_DEFAULT_PATH)
if(NOT HARFBUZZ_LIBRARY_DEBUG)
    set_target_properties(harfbuzz PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${HARFBUZZ_INCLUDE_DIR}"
        IMPORTED_CONFIGURATIONS "RELEASE"
        IMPORTED_LOCATION_RELEASE "${HARFBUZZ_LIBRARY_RELEASE}"
    )
else()
    set_target_properties(harfbuzz PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${HARFBUZZ_INCLUDE_DIR}"
        IMPORTED_CONFIGURATIONS "DEBUG;RELEASE"
        IMPORTED_LOCATION_RELEASE "${HARFBUZZ_LIBRARY_RELEASE}"
        IMPORTED_LOCATION_DEBUG "${HARFBUZZ_LIBRARY_DEBUG}"
    )
endif()

set(HARFBUZZ_FEATURES core;freetype;glib)

if(APPLE)
    find_library(APPLICATIONSERVICES_LIBRARY ApplicationServices)
    if(APPLICATIONSERVICES_LIBRARY)
        target_link_libraries(harfbuzz INTERFACE ${APPLICATIONSERVICES_LIBRARY})
    endif()    
endif()

find_dependency(freetype CONFIG)
target_link_libraries(harfbuzz INTERFACE freetype)

if ("graphite2" IN_LIST HARFBUZZ_FEATURES)
    find_library(GRAPHITE2_LIBRARY_DEBUG NAMES graphite2 PATHS "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/debug" PATH_SUFFIXES lib NO_DEFAULT_PATH)
    find_library(GRAPHITE2_LIBRARY_RELEASE NAMES graphite2 PATHS "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}" PATH_SUFFIXES lib NO_DEFAULT_PATH)
    if(NOT GRAPHITE2_LIBRARY_DEBUG)
        target_link_libraries(harfbuzz INTERFACE "${GRAPHITE2_LIBRARY_RELEASE}")
    else()
        target_link_libraries(harfbuzz INTERFACE "$<$<NOT:$<CONFIG:DEBUG>>:${GRAPHITE2_LIBRARY_RELEASE}>$<$<CONFIG:DEBUG>:${GRAPHITE2_LIBRARY_DEBUG}>")
    endif()
endif()

if ("glib" IN_LIST HARFBUZZ_FEATURES)
    find_library(GLIB_LIBRARY_DEBUG NAMES glib glib-2.0 PATHS "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/debug" PATH_SUFFIXES lib NO_DEFAULT_PATH)
    find_library(GLIB_LIBRARY_RELEASE NAMES glib glib-2.0 PATHS "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}" PATH_SUFFIXES lib NO_DEFAULT_PATH)
    if(NOT GLIB_LIBRARY_DEBUG)
        target_link_libraries(harfbuzz INTERFACE "${GLIB_LIBRARY_RELEASE}")
    else()
        target_link_libraries(harfbuzz INTERFACE "$<$<NOT:$<CONFIG:DEBUG>>:${GLIB_LIBRARY_RELEASE}>$<$<CONFIG:DEBUG>:${GLIB_LIBRARY_DEBUG}>")
    endif()
endif()

if ("icu" IN_LIST HARFBUZZ_FEATURES)
    find_dependency(ICU 61 COMPONENTS uc)
    target_link_libraries(harfbuzz INTERFACE ICU::uc)
endif()

add_library(harfbuzz::harfbuzz-subset UNKNOWN IMPORTED)

find_library(HARFBUZZ_SUBSET_LIBRARY_DEBUG 
    NAMES harfbuzz-subset 
    PATHS "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/debug" 
    PATH_SUFFIXES lib NO_DEFAULT_PATH)
find_library(HARFBUZZ_SUBSET_LIBRARY_RELEASE 
    NAMES harfbuzz-subset 
    PATHS "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}" 
    PATH_SUFFIXES lib NO_DEFAULT_PATH)
    
if(NOT HARFBUZZ_LIBRARY_DEBUG)
    set_target_properties(harfbuzz::harfbuzz-subset PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${HARFBUZZ_INCLUDE_DIR}"
        IMPORTED_CONFIGURATIONS "RELEASE"
        IMPORTED_LOCATION_RELEASE "${HARFBUZZ_SUBSET_LIBRARY_RELEASE}"
    )
else()
    set_target_properties(harfbuzz::harfbuzz-subset PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${HARFBUZZ_INCLUDE_DIR}"
        IMPORTED_CONFIGURATIONS "DEBUG;RELEASE"
        IMPORTED_LOCATION_RELEASE "${HARFBUZZ_SUBSET_LIBRARY_RELEASE}"
        IMPORTED_LOCATION_DEBUG "${HARFBUZZ_SUBSET_LIBRARY_DEBUG}"
    )
endif()

target_link_libraries(harfbuzz::harfbuzz-subset INTERFACE harfbuzz)
