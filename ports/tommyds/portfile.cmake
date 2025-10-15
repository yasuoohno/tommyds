vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

# Download the source package from GitHub.
vcpkg_from_github(
    # Specifies that the path where the source is located should be set to SOURCE_PATH.
    OUT_SOURCE_PATH SOURCE_PATH
    # Specifies the user and repository name.
    REPO amadvance/tommyds
    # Specifies the version and SHA512 for a stable build.
    REF 97ff74356f6d5ae899b9cb672deb803da01270ca
    SHA512 77cacb205990a23f07979a9b7a33789c1b86967d98ff5916e9e0e2ef3f28b4bdad0442bc73688ddc1359f4b029dc166e1ec9848a7e8f5835cbf98f951dbfc4ec
)

# Copy the custom CMakeLists.txt for vcpkg.
# The original project does not have one.
file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")

# Copy the custom tommytypes.h to provide platform-independent types.
file(COPY "${CMAKE_CURRENT_LIST_DIR}/tommytypes.h"   DESTINATION "${SOURCE_PATH}/tommyds/")

# Configure the project using CMake.
vcpkg_cmake_configure(SOURCE_PATH "${SOURCE_PATH}")

# Build and install the project.
vcpkg_cmake_install()

# Fix up the generated CMake configuration files.
vcpkg_cmake_config_fixup()

# Remove the include directory from the debug build, as it's not needed.
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

# Install the license file.
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

# Install the usage file.
configure_file("${CMAKE_CURRENT_LIST_DIR}/usage" "${CURRENT_PACKAGES_DIR}/share/${PORT}/usage" COPYONLY)
