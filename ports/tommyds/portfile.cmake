vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

set(VCPKG_USE_HEAD_VERSION ON)

# ソースパッケージをダウンロードする
vcpkg_from_github(
    # ソースが置かれたパスを SOURCE_PATH に設定する事を指定
    OUT_SOURCE_PATH SOURCE_PATH
    # リポジトリのユーザー名とリポジトリ名を指定
    REPO amadvance/tommyds
    # 安定ビルドのバージョンとSHA512を指定
    #REF "${VERSION}"
    #SHA512 0
    # 不安定ビルドのブランチを指定
    HEAD_REF master
)

# CMakeLists.txt をコピーする
file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")
file(COPY "${CMAKE_CURRENT_LIST_DIR}/tommytypes.h"   DESTINATION "${SOURCE_PATH}/tommyds/")

# CMakeLists.txt を使って Configure する
vcpkg_cmake_configure(SOURCE_PATH "${SOURCE_PATH}")
vcpkg_cmake_install()
vcpkg_cmake_config_fixup()

# debugフォルダに入った include ファイルを削除する
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

# LICENSEと usageファイルをコピーする
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
configure_file("${CMAKE_CURRENT_LIST_DIR}/usage" "${CURRENT_PACKAGES_DIR}/share/${PORT}/usage" COPYONLY)
