cmake_minimum_required(VERSION 3.30)

# CMAKE_INSTALL_INCLUDEDIR などの変数を使うために必要
include(GNUInstallDirs)

project(tommyds LANGUAGES C)

set(CMAKE_C_STANDARD   11)
set(CMAKE_CXX_STANDARD 17)

# ソースファイルとヘッダファイルを取得する
file(GLOB   tommyds_SRC "tommyds/*.c")
list(FILTER tommyds_SRC EXCLUDE REGEX ".*/tommy.c$")
file(GLOB   tommyds_HDR "tommyds/*.h")

# library の作成を指示
add_library(tommyds ${tommyds_SRC})

# インクルードディレクトリを指定する
target_include_directories(tommyds
    PRIVATE
         ${CMAKE_CURRENT_SOURCE_DIR}/tommyds
    INTERFACE
         $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/tommyds>
         $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>
)

# インストール先のディレクトリを指定する
install(TARGETS tommyds
    EXPORT tommyds_targets
    ARCHIVE DESTINATION "${CMAKE_INSTALL_LIBDIR}"
    LIBRARY DESTINATION "${CMAKE_INSTALL_LIBDIR}"
    RUNTIME DESTINATION "${CMAKE_INSTALL_BINDIR}"
)

# ヘッダファイルをインストールする
install(FILES ${tommyds_HDR}
    DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/tommyds
)

# PACKAGE-targets.cmake ファイルを生成する
install(EXPORT tommyds_targets
    FILE tommyds-targets.cmake
    NAMESPACE tommyds::
    DESTINATION share/tommyds
)

# PACKAGE-config.cmake ファイルを生成する
file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/tommyds-config.cmake"
    "include(\"\${CMAKE_CURRENT_LIST_DIR}/tommyds-targets.cmake\")\n"
)

# PACKAGE-config.cmake ファイルをインストールする
install(FILES "${CMAKE_CURRENT_BINARY_DIR}/tommyds-config.cmake"
    DESTINATION share/tommyds
)
