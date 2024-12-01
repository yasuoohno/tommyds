cmake_minimum_required(VERSION 3.29)

project(tommyds)

set(CMAKE_C_STANDARD 99)

file(GLOB TOMMYDS_SRC "tommyds/*.c")
list(FILTER TOMMYDS_SRC EXCLUDE REGEX ".*tommy.c$")
file(GLOB TOMMYDS_HDR "tommyds/*.h")

add_library(tommyds ${TOMMYDS_SRC} ${TOMMYDS_HDR})
target_include_directories(tommyds PRIVATE tommyds)

install(TARGETS tommyds)
install(FILES ${TOMMYDS_HDR} DESTINATION include/tommyds)
install(FILES tommyds-config.cmake DESTINATION share/tommyds)
