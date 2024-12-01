cmake_minimum_required(VERSION 3.29)

project(TommyDS)

set(CMAKE_C_STANDARD 99)

file(GLOB TommyDS_SRC "tommyds/*.c")
list(FILTER TommyDS_SRC EXCLUDE REGEX ".*tommy.c$")
file(GLOB TommyDS_HDR "tommyds/*.h")

add_library(tommyds ${TommyDS_SRC} ${TommyDS_HDR})
target_include_directories(tommyds PRIVATE tommyds)

install(TARGETS tommyds)
install(FILES ${TommyDS_HDR} DESTINATION include/tommyds)
install(FILES FindTommyDS.cmake DESTINATION share/tommyds)
